class AddIndexForSheetVariableResponses < ActiveRecord::Migration
  def change
    add_index :sheet_variables, :response, length: 10
  end
end
