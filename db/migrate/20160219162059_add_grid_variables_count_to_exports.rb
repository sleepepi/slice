class AddGridVariablesCountToExports < ActiveRecord::Migration
  def change
    add_column :exports, :grid_variables_count, :integer, null: false, default: 0
  end
end
