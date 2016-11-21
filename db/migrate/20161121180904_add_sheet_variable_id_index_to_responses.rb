class AddSheetVariableIdIndexToResponses < ActiveRecord::Migration[5.0]
  def change
    add_index :responses, :sheet_variable_id
  end
end
