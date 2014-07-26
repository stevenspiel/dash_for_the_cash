class User < ActiveRecord::Base

  has_many :players
  has_many :games

  scope :available, -> { where(available: true) }

  def self.delete
    User.all.each(&:destroy)
  end

  def self.delete_everything
    [User,Game,Action,Trap,Player,BasePosition].each do |model|
      model.all.each(&:destroy)
    end
  end

  def self.valid_session_id?(session)
    session[:user_id] && User.find_by(id: session[:user_id]).present?
  end
  
end