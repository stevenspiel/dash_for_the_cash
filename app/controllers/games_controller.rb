class GamesController < ApplicationController

  def new
    initiator = User.find(params[:user_id])
    opponent = User.find(params[:opponent_id])
    
    @game = Game.create!(initiator: initiator, opponent: opponent, wager: initiator.money)
    @player = @game.players.create!(user: initiator)
    @opponent = @game.players.create!(user: opponent)

    PrivatePub.publish_to("/games/new", 
      game: @game, 
      url: game_path(@game), 
      initiator_name: initiator.name, 
      initiator_id: initiator.id,
      opponent_id: opponent.id
    )

    render :show
  end

  def show
    @game = Game.find_by(id: params[:id])

    if @game && @game.has_user?(current_user) && @game.active? && @game.has_two_players?
      @player   = @game.player(current_user)
      @opponent = @game.opponent(current_user)
      @actions  = Game::ACTIONS
      unless Rails.env.production?
        @actions[:reset] = "Reset"
        @actions[:win] = "Win"
      end
    else
      binding.pry
      redirect_to :root
    end
  end

  def ready
    player_id = params[:data][:player_id]
    game_id   = params[:data][:game_id]
    game      = Game.find(game_id)

    Player.find(player_id).update_attribute(:ready, true)

    if game.players_ready?
      PrivatePub.publish_to(action_game_path(game_id), "window.beginRound();")
    else
      PrivatePub.publish_to(action_player_path(player_id), "window.playerReady();")
    end
  end

  def play
    action        = params[:move]
    game          = Game.find(params[:id])
    player        = Player.find(params[:playerId])
    opponent      = Player.find(params[:opponentId])

    if game.new_round?
      round = game.rounds.create!(first_player: player)
      player.actions.create!(round: round, action: action)
    else
      round = game.current_round
      # game/play is getting called twice sometimes. PorqUe wHy?
      return if round.first_player == player
      round.update_attributes(second_player: player)
      player.actions.create!(round: round, action: action)
      players = [player, opponent]

      players.each_with_index do |player, index|
        halt_gameplay = false

        p_action      = player.action(round).action
        message       = ""
        javascript    = ""

        opponent      = (players - [player]).first
        o_action      = opponent.action(round).action
        o_javascript  = ""

        case p_action 
        when "move"
          player.update_attribute(:position, player.position + 1)

        when "roll"
          roll = rand(1..6)
          roll = (13 - player.position) if (player.position + roll) > 13

          old_position = player.position
          traps        = opponent.active_traps
          skipped_trap = player.skipped_trap(roll, old_position, traps)

          if o_action == "defend"
            new_position = player.base_position
            message += "#{opponent.name} defended!" 
          elsif skipped_trap.present?
            skipped_trap.update_attribute(:active, false)
            new_position = player.base_position
            message += "You hit a trap!"
            o_javascript += "window.removeTrap(#{opponent.id}, #{skipped_trap.position});"
          else
            new_position = (player.position + roll)
            message += "You rolled a #{roll}."
          end

          player.update_attribute(:position, new_position)

        when "base"
          if player.can_move_base?
            player.base_positions.create!(position: player.position)
            javascript += "window.base(#{player.id}, #{player.position});"
          else
            message += "You cannot place a trap there."
          end

        when "trap"
          if player.can_place_trap?
            player.traps.create!(position: player.position)
            javascript += "window.traps(#{player.id}, #{player.position});"
          else
            message += "You cannot place a trap there."
          end

        when "fail"
          message += "Choose an option before the time runs out!"

        when "reset"
          [player, opponent].each do |p|
            p.traps.each{|trap| trap.update_attribute(:active, false)}
            p.base_positions.each(&:destroy)
            javascript += "window.baseReset(#{p.id}, #{p.position});" +
                          "window.trapsReset(#{p.id}, #{p.position});"
          end
        when "win"
          player.update_attribute(:position, 13)
        end

        javascript   += "window.move(#{player.id}, #{player.position}); window.notice('#{message}');"+
                        "window.disableButtons(#{player.position}, #{player.base_position})"
        o_javascript += "window.move(#{player.id}, #{player.position});"

        PrivatePub.publish_to(action_player_path(player.id), javascript)
        PrivatePub.publish_to(action_player_path(opponent.id), o_javascript)

        if index == 1
          if player.position < 13 && opponent.position < 13
            PrivatePub.publish_to(action_game_path(game.id), "window.restartRound();")
          else
            if player.position >= 13
              p_alert = "You won #{game.wager_to_s}!!!!".upcase
              o_alert = "You lost #{game.wager_to_s}."
              game.set_winner(winner: player, loser: opponent)
              if opponent.position >= 13
                p_alert = "It was a TIE!"
                o_alert = "It was a TIE!"
              end
            elsif opponent.position >= 13
              p_alert = "You lost #{game.wager_to_s}."
              o_alert = "You won #{game.wager_to_s}!!!".upcase
              game.set_winner(winner: opponent, loser: player)
            end

            halt_gameplay = true

            javascript   = "alert('#{p_alert}'); window.location.replace('#{ root_path }');"
            o_javascript = "alert('#{o_alert}'); window.location.replace('#{ root_path }');"

            PrivatePub.publish_to(action_player_path(player.id), javascript)
            PrivatePub.publish_to(action_player_path(opponent.id), o_javascript)
          end
        end
      end
    end
  end

  def opponent_ready
    @game = Game.find(params[:game_id])
    @initiator = User.find params[:initiator_id]
    @opponent  = User.find params[:opponent_id]

    if params[:answer] == "true"
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
