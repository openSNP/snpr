# frozen_string_literal: true

class OpenHumansProfilesController < ApplicationController
  before_action :require_user, except: [:index]

  def start_auth
    # there's little to do for the start. Just read the .env for our client_id
    # then lead ppl to OH.org to give us a key
    client_id = ENV.fetch('OH_CLIENT_ID')
    base_url = 'https://www.openhumans.org/direct-sharing/projects/oauth2/authorize/?client_id='
    redirect_to base_url + "#{client_id}&response_type=code"
  end

  def authorize
    # let's get the current user and their code
    @user = current_user
    @code = params[:code]

    # does the user have an OH profile on openSNP? if not, create one
    if @user.open_humans_profile.nil?
      @user.open_humans_profile = OpenHumansProfile.new
      @user.save
    end

    oh_service = OpenHumansService.new(@user)

    # lets convert
    oh_service.get_access_tokens(@code)
    oh_service.set_open_humans_ids
    # delete old files if there are any
    begin
      oh_service.delete_opensnp_id
    end
    oh_service.upload_opensnp_id
  end
end
