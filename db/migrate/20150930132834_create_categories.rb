class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.integer :project_id
      t.integer :user_id
      t.boolean :use_for_adverse_events, null: false, default: false
      t.string :name
      t.string :slug
      t.integer :position, null: false, default: 0
      t.text :description
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :categories, :project_id
    add_index :categories, :user_id
    add_index :categories, :deleted
  end
end
