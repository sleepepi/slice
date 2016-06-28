class CreateDesigns < ActiveRecord::Migration[4.2]
  def change
    create_table :designs do |t|
      t.string :name
      t.text :description
      t.integer :project_id
      t.integer :user_id
      t.boolean :deleted, default: false, null: false

      t.timestamps
    end
  end
end
