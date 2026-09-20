# frozen_string_literal: true

class CreateOccurrenceEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :occurrence_events do |t|
      t.references :occurrence, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :from_status
      t.string :to_status
      t.text :note

      t.timestamps
    end

    add_index :occurrence_events, :event_type
  end
end
