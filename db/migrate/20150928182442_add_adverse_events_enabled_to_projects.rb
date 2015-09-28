class AddAdverseEventsEnabledToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :adverse_events_enabled, :boolean, null: false, default: false
  end
end
