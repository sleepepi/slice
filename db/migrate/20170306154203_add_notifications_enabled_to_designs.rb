class AddNotificationsEnabledToDesigns < ActiveRecord::Migration[5.0]
  def change
    add_column :designs, :notifications_enabled, :boolean, null: false, default: false
  end
end
