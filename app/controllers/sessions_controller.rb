class SessionsController < ApplicationController
  skip_before_filter :require_login, :only => [:create, :destroy]

  def create
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to root_path
  end

  def destroy
    user = User.find(session[:user_id])
    user.update_availability(false)
    session[:user_id] = nil
    redirect_to root_path
  end
end
