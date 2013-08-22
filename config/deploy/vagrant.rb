server "localhost:2222", :app, :web, :db, :primary => true
set :deploy_to, "/srv/www/#{application}"
