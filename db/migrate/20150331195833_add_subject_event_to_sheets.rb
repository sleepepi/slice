class AddSubjectEventToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :subject_event_id, :integer
    add_index :sheets, :subject_event_id
  end
end
