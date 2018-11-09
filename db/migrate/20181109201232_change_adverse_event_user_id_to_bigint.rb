class ChangeAdverseEventUserIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :adverse_event_users, :id, :bigint
  end

  def down
    change_column :adverse_event_users, :id, :integer
  end
end
