class AddLockableToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :lockable, :boolean, null: false, default: false
  end
end
