# frozen_string_literal: true

class CreateParkings < ActiveRecord::Migration[5.2]
  def change
    create_table :parkings do |t|
      t.string :plate, null: false
      t.boolean :paid, default: false
      t.boolean :left, default: false
      t.datetime :arrived_at
      t.datetime :left_at
      t.datetime :payment_at

      t.timestamps
    end
  end
end
