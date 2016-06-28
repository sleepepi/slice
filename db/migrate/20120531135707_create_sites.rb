class CreateSites < ActiveRecord::Migration[4.2]
  def change
    create_table :sites do |t|
      t.string :name
      t.text :description
      t.integer :project_id
      t.text :emails
      t.integer :user_id
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end
