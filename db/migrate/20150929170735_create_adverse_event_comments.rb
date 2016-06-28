class CreateAdverseEventComments < ActiveRecord::Migration[4.2]
  def change
    create_table :adverse_event_comments do |t|
      t.integer :project_id
      t.integer :adverse_event_id
      t.integer :user_id
      t.text :description
      t.string :comment_type
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :adverse_event_comments, :project_id
    add_index :adverse_event_comments, :adverse_event_id
    add_index :adverse_event_comments, :user_id
  end
end
