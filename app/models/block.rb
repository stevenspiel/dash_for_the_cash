class Block < ActiveRecord::Base
  validates :position, presence: true

  belongs_to :player
  belongs_to :game

end
