class AddSheetIdToVariables < ActiveRecord::Migration[4.2]
  def up
    add_column :variables, :sheet_id, :integer
    add_index :variables, :sheet_id
  end

  def down
    remove_index :variables, :sheet_id
    remove_column :variables, :sheet_id
  end
end
