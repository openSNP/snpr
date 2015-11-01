Snpr::Application.configure do
  config.secret_token = ENV.fetch('SECRET_TOKEN')
  config.secret_key_base = ENV.fetch('SECRET_KEY_BASE')
end
