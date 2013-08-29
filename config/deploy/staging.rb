server "opensnp.org:57329", :app, :web, :db, :primary => true
set "deploy_to", "/srv/www/snpr_staging"
set :rails_env, "staging"
set :repository, "git://github.com/tsujigiri/#{application}.git"
set :branch, "capify"
