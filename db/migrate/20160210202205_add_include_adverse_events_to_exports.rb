class AddIncludeAdverseEventsToExports < ActiveRecord::Migration[4.2]
  def change
    add_column :exports, :include_adverse_events, :boolean, null: false, default: false
  end
end
