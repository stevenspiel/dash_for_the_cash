class Game < ActiveRecord::Base

  has_many   :players

  has_one    :winner,    class_name: 'User',   foreign_key: "winner_id"

  belongs_to :turn,      class_name: 'Player', foreign_key: "turn_id"
  belongs_to :initiator, class_name: 'User',   foreign_key: "initiator_id"
  belongs_to :opponent,  class_name: 'User',   foreign_key: "opponent_id"

  def you(current_user)
    players.select{ |player| player.user_id == current_user.id }.first
  end

  def them(current_user)
    players.reject{ |player| player.user_id == current_user.id }.first
  end

end
