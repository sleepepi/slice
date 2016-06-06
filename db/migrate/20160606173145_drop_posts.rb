class DropPosts < ActiveRecord::Migration
  def up
    remove_column :projects, :show_posts
    drop_table :posts
  end

  def down
    create_table :posts do |t|
      t.string :name
      t.text :description
      t.boolean :archived, null: false, default: false
      t.integer :user_id
      t.integer :project_id
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
    remove_column :projects, :show_posts, null: false, default: true
  end
end
