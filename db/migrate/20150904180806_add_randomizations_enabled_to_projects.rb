class AddRandomizationsEnabledToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :randomizations_enabled, :boolean, null: false, default: false
  end
end
