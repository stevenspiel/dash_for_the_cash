class GamesController < ApplicationController

  def new
    initiator = User.find(session[:user_id])
    opponent = User.find(params[:opponent_id])
    
    @game = Game.create!(initiator: initiator, opponent: opponent)
    @game.players.create!(user: initiator)
    @game.players.create!(user: opponent)
    @game.update_attribute(:turn_id, @game.players.first.id)

    PrivatePub.publish_to("/users/set_availability", 
      unavailable: [initiator]
    )

    PrivatePub.publish_to("/games/new", 
      game: @game, 
      url: game_path(@game), 
      initiator_name: initiator.name, 
      initiator_id: initiator.id,
      opponent_id: opponent.id
    )

    @you = initiator
    @them = opponent

    redirect_to @game
  end

  def show
    @game = Game.find params[:id]
    @you  = @game.you(current_user)
    @them = @game.them(current_user)
    @actions = {
      move:   'Move 1 Space',
      roll:   'Roll Die',
      defend: 'Defend',
      base:   'Move Base',
      trap:   'Place Trap',
      reset:  'Reset' 
    }
  end

  def play
    action     = params[:data][:action]
    game       = Game.find(params[:data][:game_id])
    played_by  = Player.find(params[:data][:played_by_id])
    played_on  = Player.find(params[:data][:played_on_id])
    javascript = ""
    alerts     = ""

    case action 
    when "move"
      played_by.update_attribute(:position, played_by.position + 1)

    when "roll"
      old_position = played_by.position
      blocks = played_by.blocks

      roll = rand(1..6)
      roll = (13 - played_by.position) if (played_by.position + roll) > 13

      if played_on.defend? || played_by.skipped_block?(old_position, roll, blocks)
        new_position = played_by.base_position 
      else
        new_position = (played_by.position + roll)
      end

      played_by.update_attribute(:position, new_position)

    when "base"
      played_by.update_attribute(:base_position, played_by.position)
      javascript = "window.base(#{played_by.id}, #{played_by.position});" +
                   "window.blocks(#{played_by.id}, #{played_by.position})"

    when "trap"
      # TODO: disable if at starting position
      played_by.blocks.create!(position: played_by.position, game: game)
      javascript = "window.blocks(#{played_by.id}, #{played_by.position});"

    when "reset"
      [played_by, played_on].each do |player|
        player.update_attributes(position: 0, base_position: 0)
        player.blocks.destroy
        player.actions.destroy
        javascript += "window.baseReset(#{player.id}, #{player.position});" +
                      "window.blocksReset(#{player.id}, #{player.position});"
      end
    end

    if played_by.position == 13
      alerts = "alert('<%= played_by.user.name.upcase %> WINS!');"
    end

    PrivatePub.publish_to(action_game_path,
      javascript +
      "window.move(#{played_by.id}, #{played_by.position});"+
      "window.turnTo(#{played_on.id});"+
      alerts
    )

    game.update_attribute(:turn, played_on)
    played_by.actions.create!(action: action, game: game)
  end

  def opponent_decision

    @game = Game.find(params[:game_id])
    @initiator = User.find params[:initiator_id]
    @opponent  = User.find params[:opponent_id]

    if params[:answer] == "true"
      # update both opponent and initiators' available statuses
      # publish to Privat Pub and remove their listings

      @game.update_attribute(:opponent_accepted, true)

      PrivatePub.publish_to("/games/opponent_decision/#{@game.id}", 
        "window.location.reload();"
      )
      render text: game_path(@game)

    else
      @game.destroy

      @initiator.update_attribute(:available, true)
      @opponent.update_attribute(:available, true)

      PrivatePub.publish_to("/games/opponent_decision/#{@game.id}", 
        "window.location.href('#{users_path}');"
      )
    end
  end

end
