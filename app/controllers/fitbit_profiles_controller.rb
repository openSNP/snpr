# frozen_string_literal: true
class FitbitProfilesController < ApplicationController
  before_action :require_user, except: [:show, :index]
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
