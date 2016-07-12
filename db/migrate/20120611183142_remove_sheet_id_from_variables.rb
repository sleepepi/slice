class RemoveSheetIdFromVariables < ActiveRecord::Migration[4.2]
  def up
    remove_index :variables, :sheet_id
    remove_column :variables, :sheet_id
  end

  def down
    add_column :variables, :sheet_id, :integer
    add_index :variables, :sheet_id
  end
end
