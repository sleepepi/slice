class ChangeSiteUserIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :site_users, :id, :bigint
  end

  def down
    change_column :site_users, :id, :integer
  end
end
