class ChangeProjectUserIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :project_users, :id, :bigint
  end

  def down
    change_column :project_users, :id, :integer
  end
end
