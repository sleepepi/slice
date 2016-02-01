class AddVariablesCountToExports < ActiveRecord::Migration
  def change
    add_column :exports, :variables_count, :integer, null: false, default: 0
  end
end
