class CreateChecks < ActiveRecord::Migration[5.0]
  def change
    create_table :checks do |t|
      t.integer :project_id
      t.integer :user_id
      t.string :name
      t.string :slug
      t.text :description
      t.boolean :archived, null: false, default: false
      t.boolean :deleted, null: false, default: false
      t.timestamps
      t.index [:project_id, :slug], unique: true
      t.index :user_id
      t.index :archived
      t.index :deleted
    end
  end
end
