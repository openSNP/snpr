# frozen_string_literal: true
ENV['RAILS_ENV'] = 'test'
require 'simplecov'
SimpleCov.start('rails') do
  coverage_dir('coverage/test-unit')
end
require File.expand_path('../../config/environment', __FILE__)
require "test/unit"
require "shoulda-context"
require "mocha/setup"
require 'rails/test_help'
require "authlogic/test_case"
require 'webmock'
WebMock.disable_net_connect!(allow_localhost: true)
require 'factory_bot_rails'
require 'paperclip/matchers'
require 'plos'
require 'spec/support/patch.rb'

Sidekiq::Logging.logger = Logger.new('log/sidekiq-test.log')

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
