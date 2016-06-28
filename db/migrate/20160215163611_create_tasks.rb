class CreateTasks < ActiveRecord::Migration[4.2]
  def change
    create_table :tasks do |t|
      t.integer :project_id
      t.integer :user_id
      t.text :description
      t.date :due_date
      t.date :window_start_date
      t.date :window_end_date
      t.boolean :completed, null: false, default: false
      t.boolean :only_unblinded, null: false, default: false
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :tasks, :project_id
    add_index :tasks, :user_id
    add_index :tasks, :due_date
    add_index :tasks, :window_start_date
    add_index :tasks, :window_end_date
    add_index :tasks, :completed
    add_index :tasks, :only_unblinded
    add_index :tasks, :deleted
  end
end
