class CreateSchedules < ActiveRecord::Migration[4.2]
  def change
    create_table :schedules do |t|
      t.string :name
      t.text :description
      t.text :items
      t.integer :project_id
      t.integer :user_id
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
