class CreateResponses < ActiveRecord::Migration[4.2]
  def change
    create_table :responses do |t|
      t.integer :variable_id
      t.text :value
      t.integer :sheet_variable_id
      t.integer :grid_id
      t.integer :user_id

      t.timestamps
    end
  end
end
