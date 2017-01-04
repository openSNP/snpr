# frozen_string_literal: true
class AdminConstraint
  def matches?(request)
    return false unless request.cookie_jar['user_credentials'].present?
    token = request.cookie_jar['user_credentials'].split(':').first
    user = User.find_by(persistence_token: token)
    user && user.admin?
  end
end
