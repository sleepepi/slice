class CreateLinks < ActiveRecord::Migration[4.2]
  def change
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
