class FitbitProfilesController < ApplicationController
  before_filter :require_user, except: [:new_notification]
  before_filter :require_user, only: [:update,:destroy,:init,:edit,:start_auth,:verify_auth,:dump]
  protect_from_forgery :except => :new_notification 

  
  def show
    @fitbit_profile = FitbitProfile.find_by_id(params[:id]) || not_found
    
    respond_to do |format|
      format.html
    end
  end
  
  def dump
    @fitbit_profile = FitbitProfile.find_by_id(params[:id]) || not_found
    Resque.enqueue(FitbitDump,current_user.email,@fitbit_profile.id)
    respond_to do |format|
      format.html
    end
  end
  
  def info
    respond_to do |format|
      format.html
    end
  end
    
  def edit
    @fitbit_profile = current_user.fitbit_profile
    respond_to do |format|
      format.html
    end
  end
  
  def destroy
    @fitbit_profile = current_user.fitbit_profile
    Resque.enqueue(FitbitEndSubscription,@fitbit_profile.id)
    respond_to do |format|
      format.html
    end
  end

  def init
    @user = current_user
    @fitbit_profile = @user.fitbit_profile
    
    respond_to do |format|
      format.html
    end
  end
  
  def update
    @fitbit_profile = FitbitProfile.find_by_id(params[:fitbit_profile][:id])
    @fitbit_profile.body = params[:fitbit_profile]["body"]
    @fitbit_profile.activities = params[:fitbit_profile]["activities"]
    @fitbit_profile.sleep = params[:fitbit_profile]["sleep"]
    @fitbit_profile.save
    Resque.enqueue(FitbitEdit,@fitbit_profile.id)
    redirect_to "/fitbit/edit"
  end

  def start_auth
    @user = current_user
    if @user.fitbit_profile == nil
      @user.fitbit_profile = FitbitProfile.new
      @user.save
    end
    print @user
    @fitbit_profile = @user.fitbit_profile 
    print @fitbit_profile
    client = Fitgem::Client.new({:consumer_key => APP_CONFIG[:fitbit_consumer_key], :consumer_secret => APP_CONFIG[:fitbit_consumer_secret]})
    request_token = client.request_token
    @fitbit_profile.request_token = request_token.token
    @fitbit_profile.request_secret = request_token.secret
    @fitbit_profile.save
    redirect_to "http://www.fitbit.com/oauth/authorize?oauth_token=#{request_token.token}"
  end
  
  def verify_auth
    @user = current_user
    @fitbit_profile = @user.fitbit_profile
    if params[:oauth_token] && params[:oauth_verifier]
      @client = Fitgem::Client.new(:consumer_key => APP_CONFIG[:fitbit_consumer_key], :consumer_secret => APP_CONFIG[:fitbit_consumer_secret])
      token = params[:oauth_token]
      secret = @fitbit_profile.request_secret
      verifier = params[:oauth_verifier]
      begin 
        access_token = @client.authorize(token, secret, { :oauth_verifier => verifier })
      rescue
        flash[:warning] = "Something went wrong while authenticating your FitBit-Account. Please try again."
        redirect_to :action => "info"
      end
      @fitbit_profile.access_token = access_token.token
      @fitbit_profile.access_secret = access_token.secret
      @fitbit_profile.verifier = verifier
      @fitbit_profile.save
      Resque.enqueue(FitbitInit,@fitbit_profile.id)
      flash[:notice] = "Successful login with FitBit!"
      redirect_to :action => "init"
    else
      flash[:warning] = "Something went wrong while authenticating your FitBit-Account. Please try again."
      redirect_to :action => "info"
    end
  end
  
  def new_notification
    puts params
    @json_object = params["updates"]
    @json_unparsed = @json_object.read
    @notification = JSON.parse(@json_unparsed)
    puts @notification[0]
    puts @notification[0]["collectionType"]
    Resque.enqueue(FitbitNotification,@notification)
    render :nothing => true, :status => 204
  end

  private

  def require_owner
    unless current_user == FitbitProfile.find(params[:fitbit_profile][:id]).user.id
      store_location
      if current_user
        return true
      else
        flash[:notice] = "You need to be logged in"
        redirect_to "/signin"
      end
      return false
    end
  end

end
