set :application, 'snpr'
set :repository, "git://github.com/gedankenstuecke/#{application}.git"
set :scm, :git
set :user, application
set :rails_env, "production"
set :use_sudo, false
set :default_stage, "production"
set :stages, %w(production staging vagrant)

require 'capistrano/ext/multistage'
require "bundler/capistrano"
require "rvm/capistrano"
require 'capistrano-unicorn'

set :rvm_ruby_string, "ruby-2.0.0-p247"
set :rvm_type, :system

after 'deploy:restart', 'unicorn:reload'
after 'deploy:restart', 'unicorn:restart'

load 'lib/capistrano/helpers'
load 'lib/capistrano/tasks/base'
load 'lib/capistrano/tasks/assets'
load 'lib/capistrano/tasks/solr'

after 'deploy:update', 'deploy:migrate'

