class Game < ActiveRecord::Base
  ACTIONS = {
    move:   'Move 1 Space',
    roll:   'Roll Die',
    defend: 'Defend',
    base:   'Move Base',
    trap:   'Place Trap'
  }

  include ActionView::Helpers::TextHelper

  has_many   :players
  has_many   :rounds
  has_many   :actions, through: :rounds

  belongs_to :initiator, class_name: 'User'
  belongs_to :opponent,  class_name: 'User'
  belongs_to :winner,    class_name: 'User'

  def player(current_user)
    players.reject{ |player| player.user_id == current_user.id }.first
  end

  def opponent(current_user)
    players.select{ |player| player.user_id == current_user.id }.first
  end

  def current_round
    rounds.last
  end

  def players_ready?
    players.all?(&:ready)
  end

  def started?
    players_ready?
  end

  def no_rounds?
    rounds.size == 0
  end

  def new_round?
    rounds.size == 0 ||
    current_round.complete?
  end

  def has_user?(user)
    players.map(&:user).include?(user)
  end

  def has_two_players?
    players.size == 2
  end

  def active?
    !winner
  end

  def set_winner(winner:, loser:)
    update_attribute(:winner, winner.user)
    winner.user.transfer_money(loser.user, wager)
  end

  def wager_to_s
    pluralize(wager, 'cent')
  end
end
