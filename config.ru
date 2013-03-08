require ::File.expand_path('../config/environment',  __FILE__)

run Rack::URLMap.new \
  "/"       => Snpr::Application
