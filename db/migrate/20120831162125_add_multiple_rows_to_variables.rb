class AddMultipleRowsToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :multiple_rows, :boolean, null: false, default: false
  end
end
