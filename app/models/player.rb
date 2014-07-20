class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :game

  has_many :actions, dependent:  :destroy
  has_many :blocks,  dependent:  :destroy

  delegate :name, to: :user

  scope :actions, -> { where(game: game) }
  scope :blocks,  -> { where(game: game) }

  def defend?
    return false if actions.none?
    actions.last.action == "defend"
  end

  def skipped_block?(old_position, roll, blocks = [])
    new_position = old_position + roll
    blocks.any? do |block|
      block.position.between?(old_position, new_position)
    end
  end
end
