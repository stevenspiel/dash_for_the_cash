class Round < ActiveRecord::Base
  before_save :validate_different_users

  belongs_to :game
  belongs_to :first_player, class_name: "Player", foreign_key: 'first_player_id'
  belongs_to :second_player, class_name: "Player", foreign_key: 'second_player_id'

  has_many :actions

  def complete?
    first_player && 
    first_player.action(self).present? && 
    second_player && 
    second_player.action(self).present?
  end

  def validate_different_users
    binding.pry if first_player == second_player
  end
end
