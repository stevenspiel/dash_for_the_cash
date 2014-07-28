class User < ActiveRecord::Base

  has_many :players
  has_many :games, foreign_key: 'initiator_id' 
  has_many :games, foreign_key: 'opponent_id'

  scope :available, -> { where("available = ? AND updated_at >= ?", true, Time.now - 1.hour) }

  def self.delete
    User.all.each(&:destroy)
  end

  def self.valid_session_id?(session)
    session[:user_id] && User.find_by(id: session[:user_id]).present?
  end

  def update_availability(availability)
    update_attribute(:available, availability)
    PrivatePub.publish_to("/users/availability", 
      user: self
    )
  end

  def self.delete_everything!
    [Action,Trap,BasePosition,Player,Game,User].each do |model|
      model.all.each(&:destroy)
    end
  end

  def date_played(user)
    games_with(user).try(:last).try(:updated_at)
  end

  def games_with(user)
    games.where(initiator: user) + games.where(opponent: user)
  end
  
end