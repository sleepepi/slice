class AddAcrosticEnabledToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :acrostic_enabled, :boolean, null: false, default: false
  end
end
