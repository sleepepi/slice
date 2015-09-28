class CreateAdverseEvents < ActiveRecord::Migration
  def change
    create_table :adverse_events do |t|
      t.integer :project_id
      t.integer :user_id
      t.integer :subject_id
      t.text :description
      t.date :adverse_event_date
      t.boolean :serious
      t.boolean :closed, null: false, default: false
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :adverse_events, :project_id
    add_index :adverse_events, :user_id
    add_index :adverse_events, :subject_id
    add_index :adverse_events, :closed
    add_index :adverse_events, :deleted
  end
end
