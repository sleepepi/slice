class ChangeProfileIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :trays, :profile_id, :bigint
  end

  def down
    change_column :trays, :profile_id, :integer
  end
end
