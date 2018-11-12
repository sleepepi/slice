class ChangeSheetUnlockRequestIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :sheet_unlock_requests, :id, :bigint

    change_column :notifications, :sheet_unlock_request_id, :bigint
  end

  def down
    change_column :sheet_unlock_requests, :id, :integer

    change_column :notifications, :sheet_unlock_request_id, :integer
  end
end
