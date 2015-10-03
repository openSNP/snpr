ENV["RAILS_ENV"] = "test"
load './spec/simplecov.rb'
require File.expand_path('../../config/environment', __FILE__)
require "test/unit"
require "shoulda-context"
require "mocha/setup"
require 'rails/test_help'
require "authlogic/test_case"
require 'webmock'
WebMock.disable_net_connect!(:allow_localhost => true)
require 'factory_girl_rails'
require 'paperclip/matchers'
require 'plos'

VCR.configure do |c|
  c.cassette_library_dir = 'test/data/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end

class ActiveSupport::TestCase
  extend Paperclip::Shoulda::Matchers
  include Authlogic::TestCase
  include WebMock::API
end
