require ::File.expand_path('../config/environment',  __FILE__)

require 'resque/server'
run Rack::URLMap.new \
  "/"       => Snpr::Application,
  "/resque" => Resque::Server.new
