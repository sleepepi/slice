class AddSheetUnlockRequestIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :sheet_unlock_request_id, :integer
    add_index :notifications, :sheet_unlock_request_id
  end
end
