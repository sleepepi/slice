class RemovePaginationFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :pagination
  end

  def down
    add_column :users, :pagination, :text
  end
end
