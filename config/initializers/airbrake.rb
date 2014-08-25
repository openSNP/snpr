# This is the config to talk to opensnperr.herokuapp.com
Airbrake.configure do |config|
  config.api_key = APP_CONFIG['ERRBIT']['API_KEY']
  config.host    = APP_CONFIG['ERRBIT']['HOST']
  config.port    = 80
  config.secure  = config.port == 443
  config.environment_name = Rails.env.production? ? `hostname` : Rails.env
end
