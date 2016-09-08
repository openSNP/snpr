class FitbitProfilesController < ApplicationController
  before_filter :require_user, except: [:new_notification, :show, :index]
  before_filter :require_user, only: [:update,:destroy,:init,:edit,:start_auth,:verify_auth,:dump]
  protect_from_forgery :except => :new_notification
  helper_method :sort_column, :sort_direction

  def index
    @title = 'Listing all connected Fitbit accounts'
    @fitbit_profiles = FitbitProfile
      .includes(:user)
      .order("#{sort_column} #{sort_direction}")
      .paginate(page: params[:page], per_page: 15)
  end

  def show
    @fitbit_profile = FitbitProfile.find_by_id(params[:id]) || not_found
    @title = 'Fitbit profile'

    #grab activity measures for graphs
    if @fitbit_profile.activities
      @activity = FitbitActivity
        .where(fitbit_profile_id: @fitbit_profile.id)
        .order(:date_logged)
      @total_length = 0 # sum of all steps which are not 0 and not nil

      @total_floors = []
      @total_steps = []
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
        @total_steps << [a.date_logged, @step_counter += a.steps]
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
      @body = FitbitBody
        .where(fitbit_profile_id: @fitbit_profile.id)
        .order(:date_logged)
      @bmi = @body.map {|fa| [fa.date_logged, fa.bmi]}
    end

    #grab sleep measurements for graphs
    if @fitbit_profile.sleep
      @sleep = FitbitSleep
        .where(fitbit_profile_id: @fitbit_profile.id)
        .order(:date_logged)

      @total_minutes_asleep = []
      @total_minutes_to_sleep = []
      @minutes_asleep = []
      @minutes_to_sleep = []
      @awakenings = []
      @total_to_sleep_counter = 0
      @total_asleep_counter = 0
      @no_sleep = 0

      @sleep.each do |s|
        # Here again, some have nils
        # Skip these
        if s.minutes_to_sleep.nil? or s.minutes_asleep.nil?
          next
        end

        if s.minutes_asleep == 0
          @no_sleep += 1
        end

        @total_minutes_to_sleep << [s.date_logged, @total_to_sleep_counter += s.minutes_to_sleep]
        @total_minutes_asleep << [s.date_logged, @total_asleep_counter += s.minutes_asleep]
        @minutes_asleep << [s.date_logged, s.minutes_asleep]
        @minutes_to_sleep << [s.date_logged, s.minutes_to_sleep]
        @awakenings << [s.date_logged, s.number_awakenings]
      end

      if not @total_minutes_asleep.empty?
        begin
          @mean_sleep = @total_minutes_asleep[-1][-1] / (@sleep.length - @no_sleep)
        rescue
        end
      end
    end
  end

  def dump
    @fitbit_profile = FitbitProfile.find_by_id(params[:id]) || not_found
    FitbitDump.perform_async(@fitbit_profile.id,current_user.id)
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
    FitbitEndSubscription.perform_async(@fitbit_profile.id)
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
    @fitbit_profile.body = params[:fitbit_profile]['body']
    @fitbit_profile.activities = params[:fitbit_profile]['activities']
    @fitbit_profile.sleep = params[:fitbit_profile]['sleep']
    @fitbit_profile.save
    FitbitEdit.perform_async(@fitbit_profile.id)
    redirect_to '/fitbit/edit'
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
    client = Fitgem::Client.new(consumer_key: ENV.fetch('FITBIT_CONSUMER_KEY'),
                                consumer_secret: ENV.fetch('FITBIT_CONSUMER_SECRET'))
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
      @client = Fitgem::Client.new(consumer_key: ENV.fetch('FITBIT_CONSUMER_KEY'),
                                   consumer_secret: ENV.fetch('FITBIT_CONSUMER_SECRET'))
      token = params[:oauth_token]
      secret = @fitbit_profile.request_secret
      verifier = params[:oauth_verifier]
      begin
        access_token = @client.authorize(token, secret, { :oauth_verifier => verifier })
      rescue
        flash[:warning] = 'Something went wrong while authenticating your FitBit-Account. Please try again'
        redirect_to :action => 'info'
      end
      @fitbit_profile.access_token = access_token.token
      @fitbit_profile.access_secret = access_token.secret
      @fitbit_profile.verifier = verifier
      @fitbit_profile.save
      FitbitInit.perform_async(@fitbit_profile.id)
      flash[:notice] = 'Successful login with FitBit'
      redirect_to :action => 'init'
    else
      flash[:warning] = 'Something went wrong while authenticating your FitBit-Account. Please try again'
      redirect_to :action => 'info'
    end
  end

  def new_notification
    puts params
    @json_object = params['updates']
    @json_unparsed = @json_object.read
    @notification = JSON.parse(@json_unparsed)
    puts @notification[0]
    puts @notification[0]['collectionType']
    FitbitNotification.perform_async(@notification)
    render :nothing => true, :status => 204
  end

  private

  def require_owner
    unless current_user == FitbitProfile.find(params[:fitbit_profile][:id]).user.id
      store_location
      if current_user
        return true
      else
        flash[:notice] = 'You need to be logged in'
        redirect_to '/signin'
      end
      return false
    end
  end

  def sort_column
    Genotype.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
  end

  def sort_direction
    %w[desc asc].include?(params[:direction]) ? params[:direction] : 'desc'
  end

end
