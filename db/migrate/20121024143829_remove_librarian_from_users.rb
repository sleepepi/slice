class RemoveLibrarianFromUsers < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :librarian
  end

  def down
    add_column :users, :librarian, :boolean, default: false, null: false
  end
end
