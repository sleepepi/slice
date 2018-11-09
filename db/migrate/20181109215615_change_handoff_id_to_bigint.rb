class ChangeHandoffIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :handoffs, :id, :bigint

    change_column :notifications, :handoff_id, :bigint
  end

  def down
    change_column :handoffs, :id, :integer

    change_column :notifications, :handoff_id, :integer
  end
end
