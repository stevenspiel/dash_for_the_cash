class Game < ActiveRecord::Base
  has_many   :players
  has_many   :rounds
  has_many   :actions, through: :rounds

  belongs_to :initiator, class_name: 'User'
  belongs_to :opponent,  class_name: 'User'
  belongs_to :winner,    class_name: 'User'

  def you(current_user)
    players.reject{ |player| player.user_id == current_user.id }.first
  end

  def them(current_user)
    players.select{ |player| player.user_id == current_user.id }.first
  end

  def current_round
    rounds.try(:last)
  end

  def players_ready?
    players.all?(&:ready)
  end

  def started?
    players_ready?
  end

  def no_rounds?
    rounds.size == 0
  end

end
