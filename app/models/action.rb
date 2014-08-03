class Action < ActiveRecord::Base
  validates :action, presence: true

  belongs_to :player
  belongs_to :round

  delegate :game, to: :round
end
