class UsersController < ApplicationController

  def index
    
    if !User.valid_session_id?(session) || !User.find(session[:user_id])
      redirect_to :root
    else
      @users = User.available - [@current_user]
      @current_user = User.find(session[:user_id])
    end
  end

  def create
    @user = User.create!(name: params[:user][:name])
    session[:user_id] = @user.id

    PrivatePub.publish_to("/users/new", user: @user)
    redirect_to :users
  end
end
