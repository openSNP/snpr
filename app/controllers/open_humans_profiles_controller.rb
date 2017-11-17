# frozen_string_literal: true

class OpenHumansProfilesController < ApplicationController
  before_action :require_user, except: [:index]

  def index
    @oh_profiles = OpenHumansProfile
                   .includes(:user)
                   .order(created_at: :desc)
                   .paginate(page: params[:page], per_page: 15)
    @user = current_user if current_user
  end

  def start_auth
    # there's little to do for the start. Just read the .env for our client_id
    # then lead ppl to OH.org to give us a key
    client_id = ENV.fetch('OH_CLIENT_ID')
    base_url = 'https://www.openhumans.org/direct-sharing/projects/oauth2/authorize/?client_id='
    redirect_to base_url + "#{client_id}&response_type=code"
  end

  def authorize
    # let's get the current user and their code
    user = current_user    
    oh_service = OpenHumansService.new(user)
    oh_service.authenticate(params[:code])
    flash[:achievement] = 'Connected your account to Open Humans'
    redirect_to user
  end

  def destroy
    oh_profile = current_user.open_humans_profile
    oh_profile.delete
    flash[:notice] = 'Your Open Humans connection was deleted.'
    redirect_to current_user
  end
end
