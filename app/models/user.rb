class User < ActiveRecord::Base
  has_many :players
  has_many :initiated_games, foreign_key: 'initiator_id', class_name: 'Game'
  has_many :opponent_games,  foreign_key: 'opponent_id',  class_name: 'Game'
  has_many :won_games,       foreign_key: 'winner_id',    class_name: 'Game'

  before_save :update_tier_preference

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end

  def self.delete
    User.all.each(&:destroy)
  end

  def first_name
    name.split(" ").first
  end

  def games
    opponent_games.merge(initiated_games)
  end

  def self.valid_session_id?(session)
    session[:user_id] && User.find_by(id: session[:user_id]).present?
  end

  def snatch_opponent(tier)
    available_users = User.where(available: true, tier_preference: tier).where.not(id: id)
    opponent = available_users.shuffle.try(:first)
    return nil unless opponent
    opponent.update_attribute(:available, false)
    update_attribute(:available, false)
    opponent
  end

  def waiting_game
    opponent_games.where(opponent_ready: false).try(:first)
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

  def transfer_money(loser, wager)
    give_money_to_winner(wager)
    take_money_from_loser(loser, wager)
  end

  def tier_options
    self.class.tier_options(money)
  end

  def self.tier_options(money)
    options = []
    i = 1

    while i <= money
      options << i
      i *= 2
    end

    options
  end

private

  def update_tier_preference
    if money_changed?
      if money_was > money || (money_was < money && had_highest_tier?)
        self.tier_preference = tier_options.last
      end
    end
  end

  def had_highest_tier?
    money_was >= self.class.tier_options(money_was).last
  end

  def give_money_to_winner(wager)
    new_amount = money + wager
    update_attribute(:money, new_amount)
  end

  def take_money_from_loser(loser, wager)
    new_amount = loser.money - wager
    new_amount = 1 if new_amount <= 0
    loser.update_attribute(:money, new_amount)
  end

end
