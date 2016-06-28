class RemoveVerifyingSheetIdFromSheets < ActiveRecord::Migration[4.2]
  def up
    remove_index :sheets, :verifying_sheet_id
    remove_column :sheets, :verifying_sheet_id
  end

  def down
    add_column :sheets, :verifying_sheet_id, :integer
    add_index :sheets, :verifying_sheet_id
  end
end
