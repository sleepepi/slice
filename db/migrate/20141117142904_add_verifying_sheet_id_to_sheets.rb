class AddVerifyingSheetIdToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :verifying_sheet_id, :integer
  end
end
