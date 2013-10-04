class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.integer :project_id
      t.integer :user_id
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
