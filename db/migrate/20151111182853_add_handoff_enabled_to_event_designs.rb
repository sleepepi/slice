class AddHandoffEnabledToEventDesigns < ActiveRecord::Migration[4.2]
  def change
    add_column :event_designs, :handoff_enabled, :boolean, null: false, default: false
    add_index :event_designs, :handoff_enabled
  end
end
