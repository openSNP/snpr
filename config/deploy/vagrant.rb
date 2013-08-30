server "localhost:2222", :app, :web, :db, :primary => true
set :deploy_to, "/srv/www/#{application}"
set :scm, :none
set :repository, "."
set :deploy_via, :copy
