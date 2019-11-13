# frozen_string_literal: true

module Requests
  module Authentication
    def sign_in_as(user)
      login(user)

      auth_params = response.headers.slice('client', 'access-token', 'expiry', 'token-type', 'uid')
      auth_params.merge!(headers_api)
      auth_params
    end

    def login(user)
      post user_session_path, params: { email: user.email, password: user.password }.to_json, headers: headers_api
    end

    def headers_api
      { 'Accept' => 'application/vnd.api+json', 'Content-Type' => 'application/vnd.api+json' }
    end
  end
end
