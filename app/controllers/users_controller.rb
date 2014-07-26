class UsersController < ApplicationController

  def index
    @current_user = User.find_by(id: session[:user_id])

    if !User.valid_session_id?(session) || !@current_user
      redirect_to :root
    else
      @available_users = User.available
      @users = @available_users - [@current_user]
    end
  end

  def create
    @user = User.create!(name: params[:user][:name])
    if session[:user_id] && User.find(session[:user_id])
      User.find(session[:user_id]).update_availability(false)
    end
    session[:user_id] = @user.id

    PrivatePub.publish_to("/users/new", user: @user)
    redirect_to :users
  end
end
