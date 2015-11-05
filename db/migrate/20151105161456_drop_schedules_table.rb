class DropSchedulesTable < ActiveRecord::Migration
  def up
    drop_table :schedules
  end

  def down
    create_table :schedules do |t|
      t.string :name
      t.text :description
      t.text :items
      t.integer :project_id
      t.integer :user_id
      t.boolean :deleted, null: false, default: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end
