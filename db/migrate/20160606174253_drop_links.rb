class DropLinks < ActiveRecord::Migration
  def up
    remove_index :links, :user_id
    remove_index :links, :project_id
    drop_table :links
  end

  def down
    create_table :links do |t|
      t.string :name
      t.string :category
      t.string :url, limit: 2000
      t.boolean :archived, null: false, default: false
      t.integer :project_id
      t.integer :user_id
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end

    add_index :links, :project_id
    add_index :links, :user_id
  end
end
