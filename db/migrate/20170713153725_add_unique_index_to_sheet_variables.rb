class AddUniqueIndexToSheetVariables < ActiveRecord::Migration[5.1]
  def change
    remove_index :sheet_variables, :sheet_id
    remove_index :sheet_variables, :variable_id
    add_index :sheet_variables, [:sheet_id, :variable_id], unique: true
  end
end
