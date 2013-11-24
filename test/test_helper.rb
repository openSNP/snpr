ENV["RAILS_ENV"] = "test"
require 'simplecov'
SimpleCov.start('rails')
require File.expand_path('../../config/environment', __FILE__)
require "test/unit"
require "shoulda-context"
require "mocha/setup"
require 'rails/test_help'
require "authlogic/test_case"
#SunspotTest.solr_startup_timeout = 30
#require 'sunspot_test/test_unit'
require 'factory_girl'
FactoryGirl.find_definitions
require 'paperclip/matchers'

class ActiveSupport::TestCase
  extend Paperclip::Shoulda::Matchers

  def stub_solr
    RSolr::Connection.any_instance.stubs(:execute)
  end
end
