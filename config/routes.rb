# frozen_string_literal: true

Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  api_version(module: 'V1', path: { value: 'v1' }) do
    get 'parkings/:plate', to: 'parkings#historic'
    put 'parkings/:id/out', to: 'parkings#out'
    put 'parkings/:id/pay', to: 'parkings#pay'
    resources :parkings, as: 'parking', only: :create
  end
end
