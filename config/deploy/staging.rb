# frozen_string_literal: true
server "opensnp.org:57329", :app, :web, :db, :primary => true
set "deploy_to", "/srv/www/snpr_staging"
set :branch, "staging"
set :rails_env, "staging"
