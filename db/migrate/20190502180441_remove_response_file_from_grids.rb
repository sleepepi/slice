class RemoveResponseFileFromGrids < ActiveRecord::Migration[6.0]
  def change
    remove_column :grids, :response_file, :text
  end
end
