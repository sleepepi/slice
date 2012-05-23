class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.integer :user_id
      t.boolean :deleted, default: false, null: false

      t.timestamps
    end
  end
end
