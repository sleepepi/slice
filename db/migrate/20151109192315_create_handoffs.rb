class CreateHandoffs < ActiveRecord::Migration
  def change
    create_table :handoffs do |t|
      t.string :token
      t.integer :user_id
      t.integer :project_id
      t.integer :subject_event_id

      t.timestamps null: false
    end

    add_index :handoffs, :user_id
    add_index :handoffs, :project_id
    add_index :handoffs, :subject_event_id
    add_index :handoffs, [:project_id, :subject_event_id], unique: true
    add_index :handoffs, [:project_id, :token], unique: true
  end
end
