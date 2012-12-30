source 'http://rubygems.org'

gem 'rails', '~> 3.0.10'
gem 'authlogic' # lots of user-related magic
gem 'rails3-generators'
gem "jquery-rails"
gem 'bartt-ssl_requirement', '~>1.4.0', :require => 'ssl_requirement'
gem 'vegas'
gem 'bcrypt-ruby', :require => "bcrypt"
gem 'rvm-capistrano'
gem 'sanitize'

# apis
gem 'fitgem'
gem 'mendeley', git: 'git://github.com/tsujigiri/mendeley.git', branch: 'paging_search'

# workaround for bug in Fedora
gem 'minitest', '~> 4.3.2'

# gem 'sqlite3'
# use postgresql instead:
gem 'pg', :require => 'pg'

# for solr (indexing, searching)
gem 'sunspot_rails'

# so we can create zip-files for genotypes
gem 'rubyzip','0.9.5', :require => 'zip/zip'

gem "will_paginate"
gem 'nested_form', :git => 'git://github.com/ryanb/nested_form.git'
gem 'json'
gem 'mediawiki-gateway'
gem 'activerecord-import'
gem 'paperclip', '~> 3.0'
gem 'friendly_id', :git => 'git://github.com/norman/friendly_id.git'
gem 'recommendify',:git => 'git://github.com/paulasmuth/recommendify.git', :ref => "34308c4"

# for jobs
gem 'resque', '1.23.0'
gem 'resque-loner'

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

group :development, :test do
  # TODO: do we need this in production?
  gem 'sunspot_solr'
end

