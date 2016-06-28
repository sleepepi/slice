class RemovePaginationFromUsers < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :pagination
  end

  def down
    add_column :users, :pagination, :text
  end
end
