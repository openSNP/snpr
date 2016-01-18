# This is the config to talk to opensnperr.herokuapp.com
Airbrake.configure do |config|
  config.api_key = ENV.fetch('ERRBIT_API_KEY')
  config.host    = ENV.fetch('ERRBIT_HOST')
  config.port    = 443
  config.secure  = config.port == 443
  config.environment_name = Rails.env.production? ? `hostname` : Rails.env
end
