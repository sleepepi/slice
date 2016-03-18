class AddAutoLockSheetsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :auto_lock_sheets, :string, null: false, default: 'never'
  end
end
