class AddMultipleRowsToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :multiple_rows, :boolean, null: false, default: false
  end
end
