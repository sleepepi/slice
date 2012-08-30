class AddGridVariablesToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :grid_variables, :text
  end
end
