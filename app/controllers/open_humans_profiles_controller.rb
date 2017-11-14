# frozen_string_literal: true
class OpenHumansProfilesController < ApplicationController
  before_filter :require_user, except: [:index]

  def start_auth
    @user = current_user
    if @user.open_humans_profile == nil
      @user.open_humans_profile = OpenHumansProfile.new
      @user.save
    end
    @oh_profile = @user.open_humans_profile

    @client_id = ENV.fetch('OH_client_id')
    redirect_to "https://www.openhumans.org/direct-sharing/projects/oauth2/authorize/?client_id=#{@client_id}&response_type=code"
  end

  def authorize
    @user = current_user
    @oh_profile = @user.open_humans_profile
    @code = params[:code]

    token_results = get_token(@code)
    @oh_profile.expires_in = Time.now + token_results["expires_in"]
    @oh_profile.access_token = token_results["access_token"]
    @oh_profile.refresh_token = token_results["refresh_token"]

    user_ids = get_open_humans_ids(@oh_profile.access_token)
    @oh_profile.project_member_id = user_ids["project_member_id"]
    @oh_profile.open_humans_user_id = user_ids["username"]
    @oh_profile.save
    upload_opensnp_id

  end

  private

  def get_token(code)
    url = URI.parse('https://www.openhumans.org/oauth2/token/')
    req = Net::HTTP::Post.new(url.request_uri)
    req.basic_auth ENV.fetch('OH_client_id'), ENV.fetch('OH_client_secret')
    req.set_form_data({'grant_type' => 'authorization_code',
                       'code' => code,
                       'redirect_uri' => "http://localhost:3000/openhumans/authorize"
                       })
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == "https")
    response = http.request(req)
    response_json = JSON.parse(response.body)
    return response_json
  end

  def get_open_humans_ids(access_token)
    uri = URI.parse('https://www.openhumans.org/api/direct-sharing/project/exchange-member/')
    uri_params = {:access_token => access_token}
    uri.query = URI.encode_www_form(uri_params)
    res = Net::HTTP.get_response(uri)
    res_json = JSON.parse(res.body)
    return res_json
  end

  def upload_opensnp_id
    @user = current_user
    user_info = generate_json
    metadata = user_info
    metadata["tags"] = ['opensnp']
    metadata["description"] = "links to openSNP user #{@user.id}"

    uri = URI.parse("https://www.openhumans.org/api/direct-sharing/project/files/upload/?access_token=#{@user.open_humans_profile.access_token}")
    @boundary = "111222XXX222111"

    post_body = []
    post_body << "--#{@boundary}\r\n"
    post_body << "Content-Disposition: form-data; name=\"project_member_id\"\r\n\r\n"
    post_body << @user.open_humans_profile.project_member_id
    post_body << "\r\n--#{@boundary}\r\n"
    post_body << "Content-Disposition: form-data; name=\"metadata\"\r\n\r\n"
    post_body << metadata.to_json
    post_body << "\r\n--#{@boundary}\r\n"
    post_body << "Content-Disposition: form-data; name=\"data_file\"; filename=\"#{@user.id}.json\"\r\n\r\n"
    post_body << user_info.to_json
    post_body << "\r\n\r\n--#{@boundary}--\r\n"

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.set_debug_output($stdout)
    upload = Net::HTTP::Post.new(uri.request_uri)
    upload.content_type = "multipart/form-data; boundary=#{@boundary}"
    upload.body = post_body.join
    response = http.request(upload)
  end

  def generate_json()
    @user = current_user
    json = {user_name: @user.name,
            user_id: @user.id,
            has_sequence: @user.has_sequence,
            user_uri: "https://opensnp.org/users/#{@user.id}"}
    return json
  end
end
