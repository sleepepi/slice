class RenameSystemAdminToAdminForUsers < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :system_admin, :admin
  end
end
