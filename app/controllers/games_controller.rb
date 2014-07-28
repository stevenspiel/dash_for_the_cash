class GamesController < ApplicationController

  def new
    initiator = User.find(session[:user_id])
    opponent = User.find(params[:opponent_id])
    
    @game = Game.create!(initiator: initiator, opponent: opponent)
    @you = @game.players.create!(user: initiator)
    @them = @game.players.create!(user: opponent)
    @game.update_attribute(:turn_id, @game.players.first.id)
    initiator.update_availability(false)    

    PrivatePub.publish_to("/games/new", 
      game: @game, 
      url: game_path(@game), 
      initiator_name: initiator.name, 
      initiator_id: initiator.id,
      opponent_id: opponent.id
    )

    redirect_to @game
  end

  def show
    unless Game.find_by(id: params[:id]) && User.valid_session_id?(session)
      redirect_to :root
    else
      @game = Game.find params[:id]
      @you  = @game.you(current_user)
      @them = @game.them(current_user)
      @actions = {
        move:   'Move 1 Space',
        roll:   'Roll Die',
        defend: 'Defend',
        base:   'Move Base',
        trap:   'Place Trap',
      }
      @actions[:reset] = "Reset" unless Rails.env.production?
    end
  end

  def play
    halt_gameplay   = false
    action          = params[:data][:action]
    game            = Game.find(params[:data][:game_id])
    played_by       = Player.find(params[:data][:played_by_id])
    played_on       = Player.find(params[:data][:played_on_id])
    javascript      = ""
    alert           = ""
    me_javascript   = ""
    them_javascript = ""

    case action 
    when "move"
      played_by.update_attribute(:position, played_by.position + 1)

    when "roll"
      roll = rand(1..6)
      roll = (13 - played_by.position) if (played_by.position + roll) > 13

      old_position = played_by.position
      traps = played_on.active_traps
      skipped_trap = played_by.skipped_trap(roll, old_position, traps)

      if played_on.defend?
        new_position = played_by.base_position
        me_javascript = "alert('#{played_on.name} defended!');" 
      elsif skipped_trap.present?
        skipped_trap.update_attribute(:active, false)
        new_position = played_by.base_position
        me_javascript = "alert('You hit a trap!');"
        them_javascript = "window.removeTrap(#{played_on.id}, #{skipped_trap.position});"
      else
        new_position = (played_by.position + roll)
      end

      played_by.update_attribute(:position, new_position)

    when "base"
      if played_by.can_move_base?
        message = "You cannot move your base any further"
        me_javascript = "alert('#{message}');"
        halt_gameplay = true
      else
        played_by.base_positions.create!(position: played_by.position)
        me_javascript = "window.base(#{played_by.id}, #{played_by.position});"
      end

    when "trap"
      if played_by.can_place_trap?
        played_by.traps.create!(position: played_by.position)
        me_javascript = "window.traps(#{played_by.id}, #{played_by.position});"
      else
        message = "You cannot place a trap here "
        me_javascript = "alert('#{message}');"
        halt_gameplay = true
      end

    when "reset"
      [played_by, played_on].each do |player|
        player.traps.each{|trap| trap.update_attribute(:active, false)}
        player.base_positions.each(&:destroy)
        player.actions.each(&:destroy)
        javascript += "window.baseReset(#{player.id}, #{player.position});" +
                      "window.trapsReset(#{player.id}, #{player.position});"
      end
    end

    if played_by.position >= 13
      played_on.user.update_availability(true)
      played_by.user.update_availability(true)
      game.update_attribute(:winner, played_by)
      alert = "alert('#{played_by.user.name.upcase} WINS!');"+
              "window.location.replace('#{users_path}');"
    end

    PrivatePub.publish_to(action_player_path(played_by.id), me_javascript)

    PrivatePub.publish_to(action_player_path(played_on.id), them_javascript)    

    unless halt_gameplay
      PrivatePub.publish_to(action_game_path(game.id),
        javascript +
        "window.move(#{played_by.id}, #{played_by.position});"+
        "window.turnTo(#{played_on.id});"+
        alert
      )

      played_by.actions.create!(action: action)
      game.update_attribute(:turn, played_on)
    end
  end

  def opponent_decision

    @game = Game.find(params[:game_id])
    @initiator = User.find params[:initiator_id]
    @opponent  = User.find params[:opponent_id]

    if params[:answer] == "true"
      @opponent.update_availability(false)

      @game.update_attribute(:opponent_accepted, true)

      PrivatePub.publish_to("/games/opponent_decision/#{@game.id}", 
        "window.location.reload();"
      )
      render text: game_path(@game)

    else
      @game.destroy

      @initiator.update_availability(true)
      @opponent.update_availability(true)

      PrivatePub.publish_to("/games/opponent_decision/#{@game.id}", 
        "window.location.replace('#{users_path}');"
      )
    end
  end

end
