class ChangeTrayIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :cubes, :tray_id, :bigint
    change_column :tray_prints, :tray_id, :bigint
  end

  def down
    change_column :cubes, :tray_id, :integer
    change_column :tray_prints, :tray_id, :integer
  end
end
