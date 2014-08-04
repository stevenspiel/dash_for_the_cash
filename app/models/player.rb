class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :game

  has_many :actions,        dependent: :destroy
  has_many :traps,          dependent: :destroy
  has_many :rounds,         dependent: :destroy
  has_many :base_positions, dependent: :destroy

  delegate :name, to: :user

  def skipped_trap(roll, old_position, traps = [])
    new_position = old_position + roll
    traps.find do |trap|
      (12 - trap.position).between?(old_position, new_position)
    end
  end

  def base_position
    base_positions.order("position DESC").try(:first).try(:position) || 0
  end

  def can_move_base?
    base_position != position
  end

  def can_place_trap?
    position != 0 && !trap_at_position?
  end

  def trap_at_position?
    traps.any?{ |trap| trap.position == position }
  end

  def active_traps
    traps.select{ |trap| trap.active? }
  end

  def action(round)
    actions.where(round: round).first
  end
end
