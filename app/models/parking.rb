# frozen_string_literal: true

class Parking < ApplicationRecord
  validates :plate, presence: true
  validates :plate, uniqueness: { scope: :left_at, message: :plate_presence }
  validates :plate, format: /[A-Z]{3}-[0-9]([A-Z]|[0-9])[0-9]{2}/i, on: :create

  validate :valid_left

  before_create :set_value_arrived_at
  before_update :set_value_left_at, :set_value_payment_at

  class << self
    def get_historic(plate)
      select(:id, :paid, :left, :arrived_at, :left_at).where(plate: plate).map do |parking|
        parking.slice(:id, :paid, :left).merge(time: parking.time)
      end
    end
  end

  def time
    return '' if arrived_at.blank? || left_at.blank?

    I18n.t('activerecord.time_parking', value: ((left_at.to_time - arrived_at.to_time) / 1.minute).to_i)
  end

  private

  def valid_left
    errors.add(:left, :valid_left) if left && !paid?
  end

  def set_value_arrived_at
    self.arrived_at = DateTime.current if arrived_at.blank?
  end

  def set_value_payment_at
    self.payment_at = DateTime.current if paid? && payment_at.blank?
  end

  def set_value_left_at
    self.left_at = DateTime.current if left? && left_at.blank?
  end
end
