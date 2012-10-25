class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :name
      t.text :description
      t.boolean :archived, null: false, default: false
      t.integer :user_id
      t.integer :project_id
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
