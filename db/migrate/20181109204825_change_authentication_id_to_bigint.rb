class ChangeAuthenticationIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :authentications, :id, :bigint
  end

  def down
    change_column :authentications, :id, :integer
  end
end
