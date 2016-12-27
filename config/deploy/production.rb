# frozen_string_literal: true
server "opensnp.org:57329", :app, :web, :db, :primary => true
set :deploy_to, "/srv/www/#{application}"
set :branch, "master"
set :rails_env, "production"
