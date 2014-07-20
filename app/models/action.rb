class Action < ActiveRecord::Base
  validates :action, presence: true

  belongs_to :player
  belongs_to :game
end
