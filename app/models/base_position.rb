class BasePosition < ActiveRecord::Base
  validates :position, presence: true

  belongs_to :player

end
