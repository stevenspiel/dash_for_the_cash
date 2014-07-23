class User < ActiveRecord::Base

  has_many :players
  has_many :games

  scope :available, -> { where(available: true) }

  def self.delete
    User.all.each(&:destroy)
  end

  def self.delete_everything
    [User,Game,Action,Block,Player].each do |model|
      model.all.each(&:destroy)
    end
  end
  
end