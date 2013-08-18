set :application, 'snpr'
set :repository, "git@github.com:gedankenstuecke/#{application}.git"
set :scm, :git
set :user, application
set :rails_env, "production"
set :use_sudo, false
set :default_stage, "production"
set :stages, %w(production staging)

require 'capistrano/ext/multistage'
require "bundler/capistrano"
require "rvm/capistrano"

set :rvm_ruby_string, "ruby-1.9.2-p290"
set :rvm_type, :system
