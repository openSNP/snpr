require 'sidekiq/web'
require ::File.expand_path('../config/environment',  __FILE__)

run Rack::URLMap.new(
  "/" => Rails.application,
  "/sidekiq" => Sidekiq::Web
)
