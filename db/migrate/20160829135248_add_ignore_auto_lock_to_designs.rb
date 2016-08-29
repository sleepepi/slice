class AddIgnoreAutoLockToDesigns < ActiveRecord::Migration[5.0]
  def change
    add_column :designs, :ignore_auto_lock, :boolean, null: false, default: false
  end
end
