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
