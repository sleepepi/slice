class RemoveDeprecatedGridVariablesFromVariables < ActiveRecord::Migration[5.0]
  def change
    remove_column :variables, :deprecated_grid_variables, :text
  end
end
