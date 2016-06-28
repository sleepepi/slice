class CreateAdverseEventFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :adverse_event_files do |t|
      t.integer :project_id
      t.integer :adverse_event_id
      t.integer :user_id
      t.string :attachment

      t.timestamps null: false
    end

    add_index :adverse_event_files, :project_id
    add_index :adverse_event_files, :adverse_event_id
    add_index :adverse_event_files, :user_id
  end
end
