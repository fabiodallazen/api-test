# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'fabio@parking.com.br' }
    password { '12345678' }
  end
end
