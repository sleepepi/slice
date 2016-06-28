class AddIndexToSheetsVerifyingSheetId < ActiveRecord::Migration[4.2]
  def change
    add_index :sheets, :verifying_sheet_id
  end
end
