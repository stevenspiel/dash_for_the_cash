class User < ActiveRecord::Base

  has_many :players
  has_many :games

  scope :available, -> { where(available: true) }

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
  
end