class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :description
      t.integer :user_id
      t.integer :sheet_id
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
    add_index :comments, :user_id
    add_index :comments, :sheet_id
  end
end
