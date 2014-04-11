class AddLockableToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :lockable, :boolean, null: false, default: false
  end
end
