class CreateGrids < ActiveRecord::Migration
  def change
    create_table :grids do |t|
      t.integer :sheet_variable_id
      t.integer :variable_id
      t.text :response
      t.text :response_file
      t.integer :user_id
      t.integer :position

      t.timestamps
    end
  end
end
