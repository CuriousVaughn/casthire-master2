class UsersController < ApplicationController
  skip_before_filter :authorize

  def new
    woopra.track 'visted new user page', {}, true
    @user = User.new

    respond_to do |format|
      format.html
    end
  end

  def create
    @user = User.new(user_params)

    if @user.save
      woopra.track 'created user', {}, true
      cookies.permanent[:auth_token] = @user.auth_token
      redirect_to root_path
    else
      woopra.track 'failed creating user', {}, true
      flash[:error] = 'Something went wrong. Please try again.'
      render action: 'new'
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
