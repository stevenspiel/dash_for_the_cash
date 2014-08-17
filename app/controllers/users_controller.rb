class UsersController < ApplicationController
  skip_before_filter :require_login, :only => :login
  before_filter :redirect_if_logged_in, :only => :login

  def index
    @user = current_user
    @message = flash[:message]
  end

  def create
    @user = User.create!(name: params[:user][:name])
    redirect_to :users
  end

  def find_opponent
    @user = User.find(params[:user_id])
    @user.update_attribute(:available, false)
    tier = @user.tier_preference
    
    if @game = @user.waiting_game
      go_to(@game)
    elsif @opponent = @user.snatch_opponent(tier)
      @game = Game.create!(initiator: @user, opponent: @opponent, wager: tier)
      @game.players.create!(user: @user)
      @game.players.create!(user: @opponent)
      redirect_to @game
    else
      flash[:message] = "No other users are currently available. Try changing your wager or try again later."
      redirect_to :users
    end
  end

  def become_searchable
    user = User.find(params[:user_id])
    tier = params[:selected_tier]
    user.update_attributes(available: true, tier_preference: tier)
  end

private 

  def go_to(game)
    game.update_attribute(:opponent_ready, true)
    PrivatePub.publish_to(ready_game_path(game), "window.location.reload();")
    redirect_to game
  end
  
  def redirect_if_logged_in
    if current_user
      redirect_to root_path
    end
  end
end
