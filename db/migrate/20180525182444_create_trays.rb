class CreateTrays < ActiveRecord::Migration[5.2]
  def change
    create_table :trays do |t|
      t.string :name
      t.text :description
      t.string :slug
      t.integer :profile_id
      t.integer :time_in_seconds, null: false, default: 0
      t.timestamps
      t.index [:slug, :profile_id], unique: true
    end
  end
end
