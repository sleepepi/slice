class AddIncludeAdverseEventsToExports < ActiveRecord::Migration
  def change
    add_column :exports, :include_adverse_events, :boolean, null: false, default: false
  end
end
