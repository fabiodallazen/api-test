# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Parking, type: :model do
  describe 'validations' do
    arrived_at = DateTime.current
    payment_at = left_at = DateTime.current + FFaker::Random.rand(100).minute

    subject { create(:parking, paid: true, left: true, arrived_at: arrived_at, left_at: left_at, payment_at: payment_at) }

    it { is_expected.to validate_presence_of(:plate) }
    it {
      expect(subject).to validate_uniqueness_of(:plate).scoped_to(:left_at).
        with_message(I18n.t('activerecord.errors.messages.plate_presence')).
        ignoring_case_sensitivity
    }
    it 'is valid if the plate is mask correct' do
      expect(build(:parking, plate: FFaker::String.from_regexp(/[A-Z][A-Z][A-Z]-[0-9][0-9][0-9][0-9]/))).to be_valid
    end
    it 'is not valid if the plate is not mask correct' do
      expect(build(:parking, plate: FFaker::String.from_regexp(/[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9]/))).not_to be_valid
    end
    it 'valid left' do
      parking = build(:parking, left: true)
      parking.valid?
      expect(parking.errors.messages[:left]).to eq([I18n.t('activerecord.errors.messages.valid_left')])
    end
  end

  describe 'callbacks' do
    context 'when created' do
      let(:parking) { build(:parking) }

      it 'have an arrival time by default' do
        parking.run_callbacks :create
        expect(parking.arrived_at).to be_truthy
      end
    end

    context 'when updated' do
      let(:parking) { create(:parking) }

      it 'have value in payment_at attribute' do
        parking.paid = true
        parking.run_callbacks :update
        expect(parking.payment_at).to be_truthy
      end
      it 'not have value in payment_at attribute' do
        parking.run_callbacks :update
        expect(parking.payment_at).to be_nil
      end
      it 'have value in left_at attribute' do
        parking.left = true
        parking.run_callbacks :update
        expect(parking.left_at).to be_truthy
      end
      it 'not have value in left_at attribute' do
        parking.run_callbacks :update
        expect(parking.left_at).to be_nil
      end
    end
  end

  describe ' class methods' do
    context 'when get the historic' do
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
        expect(Parking.get_historic(parking1.plate).first.keys).to eq(%w[id paid left time])
      end
      it 'returns two historic of vehicle' do
        create(:parking, plate: plate)
        expect(Parking.get_historic(parking1.plate).size).to eq(2)
      end
    end
  end

  describe 'object methods' do
    context 'when vehicle has parking time' do
      it 'returns correct parking time' do
        arrived_at = DateTime.current
        payment_at = left_at = DateTime.current + FFaker::Random.rand(100).minute

        parking = create(:parking, paid: true, left: true, arrived_at: arrived_at, left_at: left_at, payment_at: payment_at)
        message = I18n.t('activerecord.time_parking', value: ((left_at.to_time - arrived_at.to_time) / 1.minute).to_i)
        expect(parking.time).to eq(message)
      end
    end
  end
end
