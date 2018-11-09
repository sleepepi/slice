class ChangeGridVariableIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :grid_variables, :id, :bigint
  end

  def down
    change_column :grid_variables, :id, :integer
  end
end
