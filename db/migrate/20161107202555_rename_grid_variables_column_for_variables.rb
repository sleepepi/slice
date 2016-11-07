class RenameGridVariablesColumnForVariables < ActiveRecord::Migration[5.0]
  def change
    rename_column :variables, :grid_variables, :deprecated_grid_variables
  end
end
