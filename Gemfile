# frozen_string_literal: true
source 'https://rubygems.org'

gem 'dotenv-rails'

gem 'rails', '~> 5.0.7'
gem 'authlogic' # lots of user-related magic
gem 'i18n', '>= 0.6.6'
gem 'rails3-generators'
gem 'bcrypt-ruby', require: 'bcrypt'
gem 'sanitize'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'dynamic_form'
gem 'lograge'
gem 'slop'

# apis
gem 'mendeley', git: 'https://github.com/tsujigiri/mendeley', branch: 'paging_search'
gem 'plos', require: false

# DB
gem 'activerecord-import', '>= 0.4.0'
gem 'attr_encrypted', '< 4'
gem 'composite_primary_keys', '~> 9.0'
gem 'pg', '<1' # Unpin when updating Rails to 5.x
gem 'pg_search'

# so we can create zip-files for genotypes
gem 'rubyzip'

gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'nested_form', git: 'https://github.com/ryanb/nested_form'
gem 'json'
gem 'mediawiki-gateway', git: 'https://github.com/MusikAnimal/mediawiki-gateway'
gem 'kt-paperclip'
gem 'friendly_id'
gem 'recommendify', git: 'https://github.com/Kinoba/recommendify'

# background jobs
gem 'sidekiq', '~> 5.1.3' # TODO: Update me!
gem 'sidekiq-limit_fetch'
gem 'slim', '~> 1.3.8'
gem 'sinatra', require: false

# cron jobs
gem 'whenever', require: false

# assets
gem 'therubyracer'
gem 'execjs'
gem 'uglifier'
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 4.2.1'
gem 'sass-rails'

# monitoring
gem 'sentry-ruby'
gem 'sentry-rails'

# get rid of Ruby 2.7.7 error
# bigdecimal is required by ActiveSupport, and bigdecimal 2
# introduces some breaking changes (You cannot use BigDecimal.new)
gem 'bigdecimal', '1.3.5'
# Ruby 2.7.0 does not include scanf
gem 'scanf'

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
  gem 'webmock', '>= 3.5.0' # need at least 3.5.0 for Ruby 2.6
  gem 'vcr'
  gem 'capybara'
  gem 'selenium-webdriver', '< 4.9' # TODO: Unpin when updating Ruby
  gem 'database_cleaner'
  gem 'timecop'
  gem 'rails-controller-testing'
end

group :development, :test do
  gem 'factory_bot_rails'
  gem 'launchy'
  gem 'pry-rails', require: 'pry'
  gem 'uuidtools'
end

group :development do
  gem 'guard-rspec'
  gem 'spring'
  gem 'spring-commands-rspec'
end
