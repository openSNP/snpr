source 'http://rubygems.org'

gem 'dotenv-rails'

gem 'rails', '~> 4.2.0'
gem 'authlogic' # lots of user-related magic
gem 'i18n', '>= 0.6.6'
gem 'rails3-generators'
gem 'jquery-rails'
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'sanitize'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'dynamic_form'
gem 'lograge'
gem 'slop'

# for errbit
gem 'airbrake', '~> 4.0'

# apis
gem 'fitgem'
gem 'mendeley', github: 'tsujigiri/mendeley', branch: 'paging_search'
gem 'plos', require: false

# DB
gem 'pg'
gem 'activerecord-import', '>= 0.4.0'
gem 'composite_primary_keys', '~> 8.0'
gem 'pg_search'

# so we can create zip-files for genotypes
gem 'rubyzip'

gem 'will_paginate'
gem 'nested_form', github: 'ryanb/nested_form'
gem 'json'
gem 'mediawiki-gateway'
gem 'paperclip', '~> 4.0 '
gem 'friendly_id'
gem 'recommendify', github: 'paulasmuth/recommendify', ref: '34308c4'

# background jobs
gem 'sidekiq'
gem 'sidekiq-limit_fetch'
gem 'slim', '~> 1.3.8'
gem 'sinatra', require: false

# cron jobs
gem 'whenever', require: false

# assets
gem 'therubyracer'
gem 'execjs'
gem 'uglifier'
gem 'twitter-bootstrap-rails'
gem 'jquery-ui-rails'
gem 'sass-rails'

#group :production do
#	gem 'rpm_contrib'
#end

group :test do
  gem 'test-unit' # TODO: Remove me
  gem 'minitest' # TODO: Remove me
  gem 'rspec-rails'
  gem 'shoulda-context'
  gem 'mocha', require: false
  gem 'simplecov', require: false
  gem 'webmock'
  gem 'vcr'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'timecop'
end

group :development, :test do
  gem 'uuidtools'
  gem 'pry-rails', require: 'pry' unless ENV['CI']
  gem 'factory_girl_rails'
end

group :development do
  gem 'guard-rspec'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'capistrano', '~> 2.0'
  gem 'rvm-capistrano', '1.4.4', require: false
end
