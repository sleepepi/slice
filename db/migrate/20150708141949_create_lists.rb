class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.integer :project_id
      t.integer :randomization_scheme_id
      t.integer :user_id
      t.string :name
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :lists, :project_id
    add_index :lists, :randomization_scheme_id
    add_index :lists, :user_id
    add_index :lists, :deleted
    add_index :lists, [:randomization_scheme_id, :deleted]
  end
end
