class AddVerifyingSheetIdToSheets < ActiveRecord::Migration[4.2]
  def change
    add_column :sheets, :verifying_sheet_id, :integer
  end
end
