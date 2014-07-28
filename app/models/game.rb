class Game < ActiveRecord::Base
  has_many   :players

  belongs_to :turn,      class_name: 'Player'
  belongs_to :initiator, class_name: 'User'
  belongs_to :opponent,  class_name: 'User'
  belongs_to :winner,    class_name: 'User'

  def you(current_user)
    players.select{ |player| player.user_id == current_user.id }.first
  end

  def them(current_user)
    players.reject{ |player| player.user_id == current_user.id }.first
  end

end
