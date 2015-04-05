# TODO: Move to environment variables
begin
  Snpr::Application.configure do
    config.secret_token = File.read(Rails.root.join('secret_token'))
    config.secret_key_base = File.read(Rails.root.join('secret_key_base'))
  end
rescue LoadError, Errno::ENOENT => e
  raise "Secret token couldn't be loaded! Error: #{e}"
end
