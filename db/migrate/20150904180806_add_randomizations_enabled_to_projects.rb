class AddRandomizationsEnabledToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :randomizations_enabled, :boolean, null: false, default: false
  end
end
