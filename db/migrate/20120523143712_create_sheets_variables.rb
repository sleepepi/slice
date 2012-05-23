class CreateSheetsVariables < ActiveRecord::Migration
  def change
    create_table :sheets_variables, id: false do |t|
      t.integer :sheet_id
      t.integer :variable_id
    end
  end
end
