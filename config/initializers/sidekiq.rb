require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq/limit_fetch'


Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  u = (APP_CONFIG[:sidekiq].try(:[], "user") || "admin")
  p = (APP_CONFIG[:sidekiq].try(:[], "password") || "password")
  [user, password] == [u, p]
end
