class DropSheetsVariables < ActiveRecord::Migration[4.2]
  def up
    drop_table :sheets_variables
  end

  def down
    create_table :sheets_variables, id: false do |t|
      t.integer :sheet_id
      t.integer :variable_id
    end
  end
end
