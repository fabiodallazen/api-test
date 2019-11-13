# frozen_string_literal: true

require 'rails_helper'

describe 'whether access is ocurring properly', type: :request do
  let(:user) { create(:user) }

  context 'when occurs general authentication via API' do
    it "doesn't give you anything if you don't log in" do
      get '/v1/parkings/0', headers: headers_api
      expect(response).to have_http_status(:unauthorized)
    end

    it 'gives you an authentication code if you are an existing user and you satisfy the password' do
      login(user)
      expect(response.has_header?('access-token')).to eq(true)
    end

    it 'gives you a status 200 on signing in' do
      login(user)
      expect(response).to have_http_status(:success)
    end

    it 'first get a token, then access a restricted page' do
      get '/v1/parkings/0', headers: sign_in_as(user)
      expect(response).to have_http_status(:success)
    end

    it 'deny access to a restricted page with an incorrect token' do
      auth_params = sign_in_as(user).tap { |h| h.each { |k, _v| h[k] = '123' if k == 'access-token' } }
      get '/v1/parkings/0', headers: auth_params
      expect(response.status).not_to have_http_status(:success)
    end
  end

  RSpec.shared_examples 'use authentication tokens of different ages' do |token_age, http_status|
    let(:vary_authentication_age) { token_age }

    it 'uses the given parameter' do
      expect(vary_authentication_age(token_age)).to have_http_status(http_status)
    end

    def vary_authentication_age(token_age)
      auth_params = sign_in_as(user)

      get '/v1/parkings/0', headers: auth_params
      expect(response).to have_http_status(:success)

      allow(Time).to receive(:now).and_return(Time.now + token_age)

      get '/v1/parkings/0', headers: auth_params
      response
    end
  end

  context 'when test access tokens of varying ages' do
    include_examples 'use authentication tokens of different ages', 2.days, :success
    include_examples 'use authentication tokens of different ages', 5.years, :unauthorized
  end
end
