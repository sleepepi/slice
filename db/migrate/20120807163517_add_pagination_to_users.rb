class AddPaginationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pagination, :text
  end
end
