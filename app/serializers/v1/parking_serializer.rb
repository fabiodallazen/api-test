# frozen_string_literal: true

module V1
  class ParkingSerializer < ActiveModel::Serializer
    attributes :id, :plate, :paid, :left
  end
end
