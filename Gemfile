source 'http://rubygems.org'

gem 'rails', '~> 3.2.12'
gem 'authlogic' # lots of user-related magic
gem 'rails3-generators'
gem "jquery-rails"
gem 'bartt-ssl_requirement', '~>1.4.0', :require => 'ssl_requirement'
gem 'vegas'
gem 'bcrypt-ruby', :require => "bcrypt"
gem 'sanitize'
gem "recaptcha", :require => "recaptcha/rails"
gem 'dynamic_form'
gem 'rvm-capistrano'

# apis
gem 'fitgem'
gem 'mendeley', git: 'git://github.com/tsujigiri/mendeley.git', branch: 'paging_search'

# New Relic monitoring, off by default in development
gem 'newrelic_rpm'

# workaround for bug in Fedora
gem 'minitest', '~> 4.3.2'

# gem 'sqlite3'
# use postgresql instead:
gem 'pg', :require => 'pg'

# for solr (indexing, searching)
gem 'sunspot_rails'
gem 'sunspot_solr'

# so we can create zip-files for genotypes
gem 'rubyzip','0.9.5', :require => 'zip/zip'

gem "will_paginate"
gem 'nested_form', :git => 'git://github.com/ryanb/nested_form.git'
gem 'json'
gem 'mediawiki-gateway'
gem 'activerecord-import', '~> 0.2.11'
gem 'paperclip', '~> 3.0'
gem 'friendly_id', :git => 'git://github.com/FriendlyId/friendly_id.git', branch: '4.0-stable' # the branch is for Rails 3
gem 'recommendify',:git => 'git://github.com/paulasmuth/recommendify.git', :ref => "34308c4"

# for jobs
gem 'sidekiq'
gem 'sidekiq-limit_fetch'
gem 'slim', '~> 1.3.8'
gem 'sinatra'

group :assets do
  gem 'therubyracer'
  gem 'execjs'
  gem 'uglifier'
  gem 'yui-compressor'
  gem "twitter-bootstrap-rails"
  gem "jquery-ui-rails"
  gem 'uglifier'
end

#group :production do
#	gem 'rpm_contrib'
#	gem 'newrelic_rpm'
#end

group :test do
  gem 'shoulda-context', require: false
  gem 'factory_girl'
  gem 'mocha', require: false
  gem 'debugger'
  gem 'sunspot_test', git: 'git://github.com/tsujigiri/sunspot_test.git', branch: 'dirty_quickfix'
  #gem "turn", "< 0.8.3" # truncates backtraces in the tests (bad)
  gem 'simplecov', require: false
end

