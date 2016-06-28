class AddSheetUnlockRequestIdToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :sheet_unlock_request_id, :integer
    add_index :notifications, :sheet_unlock_request_id
  end
end
