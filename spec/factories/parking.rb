# frozen_string_literal: true

FactoryBot.define do
  factory :parking do
    plate { FFaker::String.from_regexp(/[A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9]/) }
  end
end
