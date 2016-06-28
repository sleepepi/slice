class AddPaginationToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :pagination, :text
  end
end
