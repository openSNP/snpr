class FitbitProfilesController < ApplicationController
  before_filter :require_user, except: [:new_notification, :show, :index]
  before_filter :require_user, only: [:update,:destroy,:init,:edit,:start_auth,:verify_auth,:dump]
  protect_from_forgery :except => :new_notification 
  helper_method :sort_column, :sort_direction

  def index
    @title = "Listing all connected Fitbit accounts"
    @fitbit = FitbitProfile.order(sort_column + " " + sort_direction)
    @fitbit_paginate = @fitbit.paginate(:page => params[:page],:per_page => 20)
    respond_to do |format|
      format.html
      format.xml 
    end
  end
  
  def show
    @fitbit_profile = FitbitProfile.find_by_id(params[:id]) || not_found
    @title = "Fitbit profile"
    
    #grab activity measures for graphs
    if @fitbit_profile.activities
      @activity = FitbitActivity.find_all_by_fitbit_profile_id(@fitbit_profile.id,:order => "date_logged")
      @total_length = 0 # sum of all steps which are not 0 and not nil

      @total_floors = []
      @floors = []
      @steps = []
      @floor_counter = 0
      @step_counter = 0

      @activity.each do |a|
        # Sometimes, floors is nil and not a number - API problem?
        # Dismiss these entries
        if a.steps.nil? or a.floors.nil?
          next
        end

        if a.steps != 0
          @total_length += 1
        end

        @total_floors << [a.date_logged, @floor_counter += a.floors]
        @floors << [a.date_logged, a.floors]
        @steps << [a.date_logged, a.steps]
        @total_steps << [a.date_logged, @step_counter += fa.steps]
      end

      if not @total_steps.empty?
        begin
          @mean_steps = @total_steps[-1][-1] / @total_length #@activity.length
        rescue
        end
      end
    end
    
    #grab body measurements for graphs
    if @fitbit_profile.body
      @body = FitbitBody.find_all_by_fitbit_profile_id(@fitbit_profile.id, :order => "date_logged")
      @bmi = @body.map {|fa| [fa.date_logged, fa.bmi]}
    end
    
    #grab sleep measurements for graphs
    if @fitbit_profile.sleep == true
      @sleep = FitbitSleep.find_all_by_fitbit_profile_id(@fitbit_profile.id,:order => "date_logged")
      @no_sleep = FitbitSleep.find_all_by_fitbit_profile_id_and_minutes_asleep(@fitbit_profile.id,"0")
      
      @total_asleep_counter = 0
      @total_minutes_asleep = @sleep.map {|fa| [fa.date_logged, @total_asleep_counter += fa.minutes_asleep]}
      @minutes_asleep = @sleep.map {|fa| [fa.date_logged, fa.minutes_asleep]}
      if @total_minutes_asleep.length != 0
        begin
          @mean_sleep = @total_minutes_asleep[-1][-1] / (@sleep.length - @no_sleep.length)
        rescue
        end
      end
      @total_to_sleep_counter = 0
      @total_minutes_to_sleep = @sleep.map {|fa| [fa.date_logged, @total_to_sleep_counter += fa.minutes_to_sleep]}
      @minutes_to_sleep = @sleep.map {|fa| [fa.date_logged, fa.minutes_to_sleep]}
      
      @awakenings = @sleep.map {|fa| [fa.date_logged, fa.number_awakenings]}
    end
  end
  
  def dump
    @fitbit_profile = FitbitProfile.find_by_id(params[:id]) || not_found
    Sidekiq::Client.enqueue(FitbitDump,current_user.email,@fitbit_profile.id)
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
    Sidekiq::Client.enqueue(FitbitEndSubscription,@fitbit_profile.id)
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
    Sidekiq::Client.enqueue(FitbitEdit,@fitbit_profile.id)
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
      Sidekiq::Client.enqueue(FitbitInit,@fitbit_profile.id)
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
    Sidekiq::Client.enqueue(FitbitNotification,@notification)
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
  
  def sort_column
    Genotype.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[desc asc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
