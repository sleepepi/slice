class AddAutoLockSheetsToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :auto_lock_sheets, :string, null: false, default: 'never'
  end
end
