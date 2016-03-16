class RemoveLockableFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :lockable, :boolean, null: false, default: false
    remove_column :sheets, :locked, :boolean, null: false, default: false
    remove_column :sheets, :first_locked_at, :datetime
    remove_column :sheets, :first_locked_by_id, :integer
  end
end
