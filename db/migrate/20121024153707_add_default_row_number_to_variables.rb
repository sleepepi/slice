class AddDefaultRowNumberToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :default_row_number, :integer, null: false, default: 1
  end
end
