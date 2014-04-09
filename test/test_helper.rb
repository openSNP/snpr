ENV["RAILS_ENV"] = "test"
unless ENV['CI']
  require 'simplecov'
  SimpleCov.start('rails')
end
require File.expand_path('../../config/environment', __FILE__)
require "test/unit"
require "shoulda-context"
require "mocha/setup"
require 'rails/test_help'
require "authlogic/test_case"
require 'webmock/test_unit'
WebMock.disable_net_connect!(:allow_localhost => true)
SunspotTest.solr_startup_timeout = 30
require 'sunspot_test/test_unit'
require 'factory_girl'
FactoryGirl.find_definitions
require 'paperclip/matchers'
require 'plos'
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

VCR.configure do |c|
  c.cassette_library_dir = 'test/data/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end

class ActiveSupport::TestCase
  extend Paperclip::Shoulda::Matchers

  self.use_transactional_fixtures = true

  def stub_solr
    RSolr::Connection.any_instance.stubs(:execute)
  end
end
