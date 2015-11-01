require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq/limit_fetch'


Sidekiq::Web.use(Rack::Auth::Basic) do |_user, password|
  password == ENV.fetch('SIDEKIQ_PASSWORD')
end
