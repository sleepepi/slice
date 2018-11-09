class ChangeNotificationIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :notifications, :id, :bigint
  end

  def down
    change_column :notifications, :id, :integer
  end
end
