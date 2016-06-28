class AddAdverseEventIdToSheets < ActiveRecord::Migration[4.2]
  def change
    add_column :sheets, :adverse_event_id, :integer
    add_index :sheets, :adverse_event_id
  end
end
