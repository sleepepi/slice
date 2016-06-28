class AddLibrarianToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :librarian, :boolean, default: false, null: false
  end
end
