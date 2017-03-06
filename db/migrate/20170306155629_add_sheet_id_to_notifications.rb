class AddSheetIdToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :sheet_id, :integer
    add_index :notifications, :sheet_id
  end
end
