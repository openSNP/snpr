class OpenHumansService
  # used to do the interfacing w/ Open Humans

  def get_access_tokens(user,code)
    # authenticate w/ our client id/secret against API
    # post with the key the user provided us with.
    url = URI.parse('https://www.openhumans.org/oauth2/token/')
    req = Net::HTTP::Post.new(url.request_uri)
    req.basic_auth ENV.fetch('OH_client_id'), ENV.fetch('OH_client_secret')
    req.set_form_data({'grant_type' => 'authorization_code',
                       'code' => code,
                       'redirect_uri' => "http://localhost:3000/openhumans/authorize"
                       })
    # set up request to use https
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    # do actual request, get the json it returns
    response = http.request(req)
    response_json = JSON.parse(response.body)
    update_tokens(user.open_humans_profile,response_json)
  end

  def refresh_token(user)
    oh_profile = user.open_humans_profile
    url = URI.parse('https://www.openhumans.org/oauth2/token/')
    req = Net::HTTP::Post.new(url.request_uri)
    req.set_form_data({'grant_type' => 'refresh_token',
                       'refresh_token' => oh_profile.refresh_token
                       })
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    response = http.request(req)
    response_json = JSON.parse(response.body)
    update_tokens(oh_profile,response_json)
  end


  def set_open_humans_ids(oh_profile)
    uri = URI.parse('https://www.openhumans.org/api/direct-sharing/project/exchange-member/')
    uri_params = {:access_token => oh_profile.access_token}
    uri.query = URI.encode_www_form(uri_params)
    res = Net::HTTP.get_response(uri)
    res_json = JSON.parse(res.body)
    oh_profile.project_member_id = res_json["project_member_id"]
    oh_profile.open_humans_user_id = res_json["username"]
    oh_profile.save
  end

  def upload_opensnp_id(user)
    base_url = 'https://www.openhumans.org/api/direct-sharing/project/files/upload/?access_token='
    uri = URI.parse(base_url + user.open_humans_profile.access_token)
    boundary = '0P3NSNPH34RT50PENHUM4N5'
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    upload = Net::HTTP::Post.new(uri.request_uri)
    upload.content_type = "multipart/form-data; boundary=#{boundary}"
    post_body = generate_form_body(user,boundary)
    upload.body = post_body.join
    puts post_body.join
    http.request(upload)
  end

  def delete_opensnp_id(user)
    base_url = 'https://www.openhumans.org/api/direct-sharing/project/files/delete/?access_token='
    url = URI.parse(base_url + user.open_humans_profile.access_token)
    req = Net::HTTP::Post.new(url.request_uri)
    oh_profile = user.open_humans_profile
    req.set_form_data({
                        project_member_id: oh_profile.project_member_id,
                        all_files: true
                      })
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    http.set_debug_output($stdout)
    http.request(req)
  end

  private

  def update_tokens(oh_profile,tokens)
    oh_profile.expires_in = Time.current + tokens['expires_in']
    oh_profile.access_token = tokens['access_token']
    oh_profile.refresh_token = tokens['refresh_token']
    oh_profile.save
  end

  def generate_json(user)
    json = { user_name: user.name,
             user_id: user.id,
             has_sequence: user.has_sequence,
             user_uri: "https://opensnp.org/users/#{user.id}"
           }
  end

  def generate_metadata(user)
    metadata = generate_json(user)
    metadata['tags'] = ['opensnp']
    metadata['description'] = "links to openSNP user #{user.id}"
    return metadata
  end

  def generate_form_body(user, boundary)
    metadata = generate_metadata(user)
    file_content = generate_json(user)
    post_body = []
    post_body << "--#{boundary}\r\n"
    post_body << "Content-Disposition: form-data; name=\"project_member_id\"\r\n\r\n"
    post_body << user.open_humans_profile.project_member_id
    post_body << "\r\n--#{boundary}\r\n"
    post_body << "Content-Disposition: form-data; name=\"metadata\"\r\n\r\n"
    post_body << metadata.to_json
    post_body << "\r\n--#{boundary}\r\n"
    post_body << "Content-Disposition: form-data; "
    post_body << "name=\"data_file\"; filename=\"#{user.id}.json\"\r\n\r\n"
    post_body << file_content.to_json
    post_body << "\r\n\r\n--#{boundary}--\r\n"
  end
end
