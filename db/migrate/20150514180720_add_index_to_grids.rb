class AddIndexToGrids < ActiveRecord::Migration[4.2]
  def change
    add_index :grids, :sheet_variable_id
    add_index :grids, :variable_id
    add_index :grids, :user_id
  end
end
