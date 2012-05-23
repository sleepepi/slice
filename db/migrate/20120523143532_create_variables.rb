class CreateVariables < ActiveRecord::Migration
  def change
    create_table :variables do |t|
      t.string :name
      t.text :description
      t.string :header
      t.string :variable_type
      t.text :values
      t.text :response
      t.integer :user_id
      t.integer :project_id
      t.boolean :deleted, default: false, null: false

      t.timestamps
    end
  end
end
