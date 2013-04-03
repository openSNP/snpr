require 'sidekiq'
require 'sidekiq/web'
require 'sidekiq/limit_fetch'

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
      [user, password] == ["admin", "password"]
end
