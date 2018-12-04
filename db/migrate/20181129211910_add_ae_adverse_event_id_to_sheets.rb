class AddAeAdverseEventIdToSheets < ActiveRecord::Migration[5.2]
  def change
    add_column :sheets, :ae_adverse_event_id, :bigint
    add_index :sheets, :ae_adverse_event_id
  end
end
