class AddIndexToSheetsVerifyingSheetId < ActiveRecord::Migration
  def change
    add_index :sheets, :verifying_sheet_id
  end
end
