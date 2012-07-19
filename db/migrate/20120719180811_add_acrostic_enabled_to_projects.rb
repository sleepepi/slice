class AddAcrosticEnabledToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :acrostic_enabled, :boolean, null: false, default: false
  end
end
