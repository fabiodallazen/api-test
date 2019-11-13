# frozen_string_literal: true

module V1
  class ParkingsController < ApplicationController
    include ErrorSerializer

    before_action :authenticate_user!
    before_action :set_parking, only: %i[out pay]

    def create
      parking = Parking.new(parking_params)

      if parking.save
        render json: parking, status: :created
      else
        render json: ErrorSerializer.serialize(parking.errors), status: :unprocessable_entity
      end
    end

    def out
      if @parking.update(left: true)
        render json: @parking, status: :ok
      else
        render json: ErrorSerializer.serialize(@parking.errors), status: :unprocessable_entity
      end
    end

    def pay
      if @parking.update(paid: true)
        render json: @parking, status: :ok
      else
        render json: ErrorSerializer.serialize(@parking.errors), status: :unprocessable_entity
      end
    end

    def historic
      parkings = Parking.get_historic(params[:plate])
      render json: parkings, status: :ok if stale?(etag: parkings)
    end

    private

    def set_parking
      @parking = Parking.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { "errors": [{ "id": 'Not found', "title": e.message }] }, status: :not_found
    end

    def parking_params
      params.permit(:plate)
    end
  end
end
