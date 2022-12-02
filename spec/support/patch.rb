# Rails 4.2 call `initialize` inside `recycle!`. However Ruby 2.6 doesn't allow calling `initialize` twice.
# Rails refuse to patch that as Rails 4 is old.
# See for detail: https://github.com/rails/rails/issues/34790
if RUBY_VERSION.to_f >= 2.6 && Rails::VERSION::MAJOR == 4
  class ActionController::TestResponse
    prepend Module.new {
      def recycle!
        @mon_mutex_owner_object_id = nil
        @mon_mutex = nil
        super
      end
    }
  end
end
