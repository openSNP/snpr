class UserSession < Authlogic::Session::Base
  # rails 3 broke something, this is for fix
  def to_key
    new_record? ? nil : [send(self.class.primary_key)]
  end
end
