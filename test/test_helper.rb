# frozen_string_literal: true
ENV['RAILS_ENV'] = 'test'
require 'simplecov'
SimpleCov.command_name 'test:unit'
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

# From https://github.com/rails/rails/issues/34790
#
# This is required because of an incompatibility between Ruby 2.6 and Rails 4.2, which the Rails team is not going to fix.

rb_version = Gem::Version.new(RUBY_VERSION)

if rb_version >= Gem::Version.new('2.6') && Gem::Version.new(Rails.version) < Gem::Version.new('5')
  if ! defined?(::ActionController::TestResponse)
    raise "Needed class is not defined yet, try requiring this file later."
  end

  if rb_version >= Gem::Version.new('2.7')
    puts "Using #{__FILE__} for Ruby 2.7."

    class ActionController::TestResponse < ActionDispatch::TestResponse
      def recycle!
        @mon_data = nil
        @mon_data_owner_object_id = nil
        initialize
      end
    end

    class ActionController::LiveTestResponse < ActionController::Live::Response
      def recycle!
        @body = nil
        @mon_data = nil
        @mon_data_owner_object_id = nil
        initialize
      end
    end

  else
    puts "Using #{__FILE__} for Ruby 2.6."

    class ActionController::TestResponse < ActionDispatch::TestResponse
      def recycle!
        @mon_mutex = nil
        @mon_mutex_owner_object_id = nil
        initialize
      end
    end

    class ActionController::LiveTestResponse < ActionController::Live::Response
      def recycle!
        @body = nil
        @mon_mutex = nil
        @mon_mutex_owner_object_id = nil
        initialize
      end
    end

  end
else
  puts "#{__FILE__} no longer needed."
end
