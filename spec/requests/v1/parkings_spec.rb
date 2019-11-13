# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::ParkingsController, type: :request do
  let(:user) { create(:user) }

  describe 'POST /v1/parkings' do
    context 'when it has valid parameters' do
      it 'creates the parking with correct attributes' do
        parking_attributes = attributes_for(:parking)
        post "/v1/parkings?plate=#{parking_attributes[:plate]}", headers: sign_in_as(user)
        expect(response).to have_http_status(:created)
      end
    end

    context 'when it has no valid parameters' do
      it 'does not create parking' do
        post '/v1/parkings?plate=0', headers: sign_in_as(user)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when it has no valid headers' do
      it 'request parking and return unsupported_media_type' do
        post '/v1/parkings?plate=0', headers: sign_in_as(user).except('Content-Type')
        expect(response).to have_http_status(:unsupported_media_type)
      end
      it 'request parking and return not_acceptable' do
        post '/v1/parkings?plate=0', headers: sign_in_as(user).except('Accept')
        expect(response).to have_http_status(:not_acceptable)
      end
    end
  end

  describe 'PUT /v1/parkings/:id/out' do
    context 'when the parking exists and paid' do
      let(:parking) { create(:parking, paid: true) }

      before { put "/v1/parkings/#{parking.id}/out", headers: sign_in_as(user) }

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end
      it 'returns the parking ok' do
        object = parking.reload
        expect(json['data']['attributes']['left']).to eq(object.left)
      end
    end

    context 'when the parking exists and not paid' do
      let(:parking) { create(:parking) }

      before { put "/v1/parkings/#{parking.id}/out", headers: sign_in_as(user) }

      it 'returns status unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'returns the parking unprocessable_entity' do
        expect(json['errors'][0]['title']).to eq(I18n.t('activerecord.errors.messages.valid_left'))
      end
    end

    context 'when the parking does not exist' do
      before { put '/v1/parkings/0/out', headers: sign_in_as(user) }

      it 'returns status code 404' do
        expect(response).to have_http_status(:not_found)
      end
      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Parking/)
      end
    end

    context 'when it has no valid headers' do
      it 'request parking and return unsupported_media_type' do
        put '/v1/parkings/0/out', headers: sign_in_as(user).except('Content-Type')
        expect(response).to have_http_status(:unsupported_media_type)
      end
      it 'request parking and return not_acceptable' do
        put '/v1/parkings/0/out', headers: sign_in_as(user).except('Accept')
        expect(response).to have_http_status(:not_acceptable)
      end
    end
  end

  describe 'PUT /v1/parkings/:id/pay' do
    context 'when the parking exists' do
      let(:parking) { create(:parking) }

      before { put "/v1/parkings/#{parking.id}/pay", headers: sign_in_as(user) }

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end
      it 'returns the parking ok' do
        object = parking.reload
        expect(json['data']['attributes']['paid']).to eq(object.paid)
      end
    end

    context 'when the parking does not exist' do
      before { put '/v1/parkings/0/pay', headers: sign_in_as(user) }

      it 'returns status code 404' do
        expect(response).to have_http_status(:not_found)
      end
      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Parking/)
      end
    end

    context 'when it has no valid headers' do
      it 'request parking and return unsupported_media_type' do
        put '/v1/parkings/0/pay', headers: sign_in_as(user).except('Content-Type')
        expect(response).to have_http_status(:unsupported_media_type)
      end
      it 'request parking and return not_acceptable' do
        put '/v1/parkings/0/pay', headers: sign_in_as(user).except('Accept')
        expect(response).to have_http_status(:not_acceptable)
      end
    end
  end

  describe 'GET /v1/parkings/:plate' do
    context 'when the parking exist' do
      arrived_at = DateTime.current
      left_at = DateTime.current + FFaker::Random.rand(100).minute
      plate = FFaker::String.from_regexp(/[A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9]/)
      let(:parking1) do
        create(
          :parking,
          plate: plate, paid: true, left: true, arrived_at: arrived_at, left_at: left_at, payment_at: left_at
        )
      end

      it 'returns keys of historic' do
        get "/v1/parkings/#{parking1.plate}", headers: sign_in_as(user)
        expect(json.first.keys).to eq(%w[id paid left time])
      end
      it 'returns two historic of vehicle' do
        create(:parking, plate: plate)
        get "/v1/parkings/#{parking1.plate}", headers: sign_in_as(user)
        expect(json.size).to eq(2)
      end
    end

    context 'when the parking does not exist' do
      before { get '/v1/parkings/0', headers: sign_in_as(user) }

      it 'returns status ok' do
        expect(response).to have_http_status(:ok)
      end
      it 'returns a not found message' do
        expect(json['data']).to eq([])
      end
    end

    context 'when it has no valid headers' do
      it 'request parking and return ok' do
        get '/v1/parkings/0', headers: sign_in_as(user).except('Content-Type')
        expect(response).to have_http_status(:ok)
      end
      it 'request parking and return not_acceptable' do
        get '/v1/parkings/0', headers: sign_in_as(user).except('Accept')
        expect(response).to have_http_status(:not_acceptable)
      end
    end
  end
end
