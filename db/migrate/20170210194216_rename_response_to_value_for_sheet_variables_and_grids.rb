class RenameResponseToValueForSheetVariablesAndGrids < ActiveRecord::Migration[5.0]
  def change
    rename_column :grids, :response, :value
    rename_column :sheet_variables, :response, :value
  end
end
