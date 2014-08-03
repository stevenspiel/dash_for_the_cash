class Round < ActiveRecord::Base
  belongs_to :game

  has_many :actions

  def complete?
    first_player && second_player && actions.size == 2
  end
end
