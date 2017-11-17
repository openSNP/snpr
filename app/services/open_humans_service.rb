# frozen_string_literal: true

class OpenHumansService
  # used to do the interfacing w/ Open Humans
  BASE_API_URL = 'https://www.openhumans.org/api/direct-sharing/project'
  BOUNDARY = '0P3NSNPH34RT50PENHUM4N5'

  def initialize(user)
    @user = user
    @oh_profile = @user.open_humans_profile
  end

  def authenticate(code)
    # lets convert
    get_access_tokens(code)
    set_open_humans_ids
    # delete old files if there are any
    begin
      delete_opensnp_id
    end
    upload_opensnp_id
  end

  def get_access_tokens(code)
    # authenticate w/ our client id/secret against API
    # post with the key the user provided us with.
    url = URI.parse('https://www.openhumans.org/oauth2/token/')
    req = Net::HTTP::Post.new(url.request_uri)
    req.basic_auth ENV.fetch('OH_CLIENT_ID'), ENV.fetch('OH_CLIENT_SECRET')
    req.set_form_data('grant_type' => 'authorization_code',
                      'code' => code,
                      'redirect_uri' => OH_REDIRECT_URL)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    response = http.request(req)
    update_tokens(JSON.parse(response.body))
  end

  def refresh_token
    url = URI.parse('https://www.openhumans.org/oauth2/token/')
    req = Net::HTTP::Post.new(url.request_uri)
    req.set_form_data('grant_type' => 'refresh_token',
                      'refresh_token' => @oh_profile.refresh_token)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    response = http.request(req)
    update_tokens(JSON.parse(response.body))
  end

  def set_open_humans_ids
    uri = URI.parse(BASE_API_URL + '/exchange-member/')
    uri_params = { access_token: @oh_profile.access_token }
    uri.query = URI.encode_www_form(uri_params)
    res = Net::HTTP.get_response(uri)
    res_json = JSON.parse(res.body)
    @oh_profile.project_member_id = res_json['project_member_id']
    @oh_profile.open_humans_user_id = res_json['username']
    @oh_profile.save
  end

  def upload_opensnp_id
    base_url = BASE_API_URL + '/files/upload/?access_token='
    uri = URI.parse(base_url + @oh_profile.access_token)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    upload = Net::HTTP::Post.new(uri.request_uri)
    upload.content_type = "multipart/form-data; BOUNDARY=#{BOUNDARY}"
    upload.body = generate_form_body
    http.request(upload)
  end

  def delete_opensnp_id
    base_url = BASE_API_URL + '/files/delete/?access_token='
    url = URI.parse(base_url + @oh_profile.access_token)
    req = Net::HTTP::Post.new(url.request_uri)
    req.set_form_data(project_member_id: @oh_profile.project_member_id, all_files: true)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    http.request(req)
  end

  private

  def update_tokens(tokens)
    @oh_profile.expires_in = Time.current + tokens['expires_in']
    @oh_profile.access_token = tokens['access_token']
    @oh_profile.refresh_token = tokens['refresh_token']
    @oh_profile.save
  end

  def generate_json
    { user_name: @user.name,
      user_id: @user.id,
      has_sequence: @user.has_sequence,
      user_uri: "https://opensnp.org/users/#{@user.id}" }
  end

  def generate_metadata
    metadata = generate_json
    metadata['tags'] = ['opensnp']
    metadata['description'] = "links to openSNP user #{@user.id}"
    metadata
  end

  def generate_form_body
    metadata = generate_metadata
    file_content = generate_json
    <<-POST_BODY.strip_heredoc
      --#{BOUNDARY}\r
      Content-Disposition: form-data; name="project_member_id"\r\n\r
      #{@oh_profile.project_member_id}\r
      --#{BOUNDARY}\r
      Content-Disposition: form-data; name="metadata"\r\n\r
      #{metadata.to_json}\r
      --#{BOUNDARY}\r
      Content-Disposition: form-data; name="data_file"; filename="#{@user.id}.json"\r\n\r
      #{file_content.to_json}\r
      --#{BOUNDARY}--\r\n\r
    POST_BODY
  end
end
