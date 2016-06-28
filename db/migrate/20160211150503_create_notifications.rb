class CreateNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.boolean :read, null: false, default: false
      t.integer :project_id
      t.integer :adverse_event_id
      t.integer :comment_id
      t.integer :handoff_id

      t.timestamps null: false
    end

    add_index :notifications, :user_id
    add_index :notifications, :read
    add_index :notifications, :project_id
    add_index :notifications, :adverse_event_id
    add_index :notifications, :comment_id
    add_index :notifications, :handoff_id
  end
end
