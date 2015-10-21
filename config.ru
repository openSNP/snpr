require 'sidekiq/web'
require ::File.expand_path('../config/environment',  __FILE__)

Sidekiq::Web.use Rack::Session::Cookie, :secret => ENV['RACK_SESSION_COOKIE']
Sidekiq::Web.instance_eval { @middleware.reverse! } # make session the first middleware to run
run Rack::URLMap.new(
  "/" => Rails.application,
  "/sidekiq" => Sidekiq::Web
)
