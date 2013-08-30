set :application, 'snpr'
set :repository, "git://github.com/gedankenstuecke/#{application}.git"
set :scm, :git
set :user, application
set :rails_env, "production"
set :use_sudo, false
set :default_stage, "production"
set :stages, %w(production staging vagrant)

require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'rvm/capistrano'
require 'sidekiq/capistrano'

set :rvm_ruby_string, "ruby-2.0.0-p247"
set :rvm_type, :system

load 'lib/capistrano/helpers'
load 'lib/capistrano/tasks/base'
load 'lib/capistrano/tasks/assets'
load 'lib/capistrano/tasks/solr'
load 'lib/capistrano/tasks/passenger'

after 'deploy:update', 'deploy:migrate'
after 'deploy:restart', 'passenger:restart'

