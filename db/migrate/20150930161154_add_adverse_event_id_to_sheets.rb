class AddAdverseEventIdToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :adverse_event_id, :integer
    add_index :sheets, :adverse_event_id
  end
end
