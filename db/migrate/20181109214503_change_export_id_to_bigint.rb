class ChangeExportIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :exports, :id, :bigint

    change_column :notifications, :export_id, :bigint
  end

  def down
    change_column :exports, :id, :integer

    change_column :notifications, :export_id, :integer
  end
end
