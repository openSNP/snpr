# frozen_string_literal: true
class UserSession < Authlogic::Session::Base
  after_persisting :raven_set_user_context
  after_destroy :raven_clear_user_context

  # rails 3 broke something, this is for fix
  def to_key
    new_record? ? nil : [self.send(self.class.primary_key)]
  end

  def raven_set_user_context
    Raven.user_context(
      'id' => self.user.id,
      'email' => self.user.email,
      'username' => self.user.name
    )
  end

  def raven_clear_user_context
    Raven.user_context({})
  end
end
