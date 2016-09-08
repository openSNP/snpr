class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all
  helper_method :current_user_session, :current_user

  def not_found
    raise ActionController::RoutingError.new('Not found')
  end

  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def require_user
    unless current_user
      store_location
      flash[:warning] = 'You must be logged in to access this page'
      redirect_to root_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:warning] = 'You must be logged out to access this page'
      redirect_to current_user
      return false
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end
