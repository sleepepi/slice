class AddEventIdAndSubjectScheduleIdToSheets < ActiveRecord::Migration
  def change
    add_column :sheets, :event_id, :integer
    add_column :sheets, :subject_schedule_id, :integer

    add_index :sheets, :event_id
    add_index :sheets, :subject_schedule_id
  end
end
