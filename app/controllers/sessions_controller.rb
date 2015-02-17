class SessionsController < ApplicationController
  skip_before_filter :authorize, only: [:new, :create]

  def new
    woopra.track 'visited login page', {}, true
  end

  def create
    user = User.find_by_email(params[:email])

    if user && user.authenticate(params[:password])
      woopra.track 'logged in', {}, true
      cookies.permanent[:auth_token] = user.auth_token
      redirect_to root_path
    else
      woopra.track 'failed login', {}, true
      flash[:error] = 'Invalid email or password.'
      redirect_to new_session_path
    end
  end

  def destroy
    woopra.track 'logged out', {}, true
    cookies.delete(:auth_token)

    redirect_to root_path
  end
end
