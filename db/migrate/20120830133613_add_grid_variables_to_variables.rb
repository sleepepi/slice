class AddGridVariablesToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :grid_variables, :text
  end
end
