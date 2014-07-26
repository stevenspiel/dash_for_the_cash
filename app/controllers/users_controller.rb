class UsersController < ApplicationController

  def index
    if !User.valid_session_id?(session)
      redirect_to :root
    else
      @current_user = User.find(session[:user_id])
      @users = User.available - [@current_user]
    end
  end

  def create
    @user = User.create!(name: params[:user][:name])
    session[:user_id] = @user.id

    PrivatePub.publish_to("/users/new", user: @user)
    redirect_to :users
  end

  def update
    # PrivatePub.publish_to("/users/available", user: @user) if params[:available]
    # PrivatePub.publish_to("/users/unavailable", user: @user) if params[:unavailable]
  end
end
