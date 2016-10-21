class AddExportIdToNotifications < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :export_id, :integer
    add_index :notifications, :export_id
  end
end
