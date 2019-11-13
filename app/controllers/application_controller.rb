# frozen_string_literal: true

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :ensure_json_request

  def ensure_json_request
    render body: nil, status: :not_acceptable unless request.headers['Accept'] =~ /vnd\.api\+json/

    return if request.get? || request.headers['Content-Type'] =~ /vnd\.api\+json/

    render body: nil, status: :unsupported_media_type
  end
end
