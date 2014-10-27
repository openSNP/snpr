source 'http://rubygems.org'

gem 'rails', '~> 3.2.18'
gem 'authlogic' # lots of user-related magic
gem 'i18n', '>= 0.6.6'
gem 'rails3-generators'
gem "jquery-rails"
gem 'vegas'
gem 'bcrypt-ruby', :require => "bcrypt"
gem 'sanitize'
gem "recaptcha", :require => "recaptcha/rails"
gem 'dynamic_form'

# for errbit
gem 'airbrake'

# apis
gem 'fitgem'
gem 'mendeley', github: 'tsujigiri/mendeley', branch: 'paging_search'
gem 'plos', require: false

# New Relic monitoring, off by default in development
gem 'newrelic_rpm'

# DB
gem 'pg'
gem 'activerecord-import', '~> 0.2.11'
gem 'composite_primary_keys'
gem 'pg_search'

# so we can create zip-files for genotypes
gem 'rubyzip', :git => 'git://github.com/rubyzip/rubyzip.git'

gem "will_paginate"
gem 'nested_form', github: 'ryanb/nested_form'
gem 'json'
gem 'mediawiki-gateway'
gem 'paperclip', '~> 4.0 '
gem 'friendly_id', github: 'FriendlyId/friendly_id', branch: '4.0-stable' # the branch is for Rails 3
gem 'recommendify', github: 'paulasmuth/recommendify', :ref => "34308c4"

# background jobs
gem 'sidekiq'
gem 'sidekiq-limit_fetch'
gem 'slim', '~> 1.3.8'
gem 'sinatra'

# cron jobs
gem 'whenever', require: false

group :assets do
  gem 'therubyracer'
  gem 'execjs'
  gem 'uglifier'
  gem 'yui-compressor'
  gem "twitter-bootstrap-rails"
  gem 'sass'
  gem "jquery-ui-rails"
end

#group :production do
#	gem 'rpm_contrib'
#	gem 'newrelic_rpm'
#end

group :test do
  gem 'shoulda-context', require: false
  gem 'factory_girl_rails'
  gem 'mocha', require: false
  gem 'simplecov', require: false
  gem 'webmock'
  gem 'vcr'
  gem 'capybara'
  gem 'database_cleaner'
end

group :development, :test do
  gem 'uuidtools'
  gem 'rspec-rails'
  gem 'pry-rails', require: 'pry' unless ENV['CI']
end

group :development do
  gem 'guard-rspec'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'capistrano', '~> 2.0'
  gem 'rvm-capistrano', '1.4.4'
end
