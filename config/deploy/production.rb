server "opensnp.org:57329", :app, :web, :db, :primary => true
set :deploy_to, "/srv/www/#{application}"
