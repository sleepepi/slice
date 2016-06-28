class AddSubjectEventToSheets < ActiveRecord::Migration[4.2]
  def change
    add_column :sheets, :subject_event_id, :integer
    add_index :sheets, :subject_event_id
  end
end
