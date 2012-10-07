require 'capistrano/ext/multistage'
default_run_options[:pty] = true 
set :stages, %w(production staging)
set :default_stage, "staging"

set :application, "opensnp"
set :scm, :git
set :user, "bastian"
set :use_sudo, false
set :port, 57329
set :scm_user, "drsnuggles"
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
#
set :repository, "https://github.com/gedankenstuecke/snpr.git"
set :deploy_via, :remote_cache
set :rails_env, "production"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
