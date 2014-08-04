class User < ActiveRecord::Base
  has_many :players
  has_many :games, foreign_key: 'initiator_id' 
  has_many :games, foreign_key: 'opponent_id'
  has_many :games, foreign_key: 'winner_id'

  scope :available, -> { where("available = ? AND updated_at >= ?", true, Time.now - 10.minutes) }

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.update_availability(true)
      user.save!
    end
  end

  def self.delete
    User.all.each(&:destroy)
  end

  def self.valid_session_id?(session)
    session[:user_id] && User.find_by(id: session[:user_id]).present?
  end

  def update_availability(availability)
    if available != availability
      update_attribute(:available, availability)
      PrivatePub.publish_to("/users/available_members", 
        user: self
      )
    end
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