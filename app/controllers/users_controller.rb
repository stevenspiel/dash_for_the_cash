class UsersController < ApplicationController
  skip_before_filter :require_login, :only => :login
  before_filter :redirect_if_logged_in, :only => :login

  def index
    @current_user = User.find_by(id: session[:user_id])
    @current_user.update_availability(true)
    @available_users = User.available
    @users = @available_users - [@current_user]
  end

  def create
    @user = User.create!(name: params[:user][:name])

    if session[:user_id] && User.find_by(id: session[:user_id])
      User.find(session[:user_id]).update_availability(true)
    end

    redirect_to :users
  end

  def update_availability
    availability = params[:available]
    id = params[:id]
    user = Player.find(id).user
    user.update_availability(availability)
  end

  private def redirect_if_logged_in
    if current_user
      redirect_to root_path
    end
  end
end
