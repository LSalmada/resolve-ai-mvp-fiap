# frozen_string_literal: true

class CreateOccurrences < ActiveRecord::Migration[8.0]
  def change
    create_table :occurrences do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :location, null: false
      t.string :category, null: false
      t.string :status, null: false, default: "aberta"
      t.string :priority, null: false, default: "media"
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.references :assignee, null: true, foreign_key: { to_table: :users }
      t.text :resolution_notes
      t.integer :rating
      t.text :rating_comment

      t.timestamps
    end

    add_index :occurrences, :status
    add_index :occurrences, :category
    add_index :occurrences, :priority
  end
end
