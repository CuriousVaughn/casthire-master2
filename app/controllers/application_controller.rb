include WoopraRailsSDK

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :signed_in?, :current_user

  before_filter :woopra, :current_user

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end

  def signed_in?
    true if current_user
  end

  def authorize
    unless signed_in?
      respond_to do |format|
        format.html { redirect_to new_session_path, :alert => 'Please sign in to continue.' }
      end
    end
  end

  def woopra
    woopra = WoopraTracker.new(request)
    @woopra_code = woopra.js_code
    woopra.config({ domain: 'casthire.com' })
    woopra.identify({ email: current_user.email }).track if current_user
    woopra.set_woopra_cookie(cookies)
    woopra
  end
end
