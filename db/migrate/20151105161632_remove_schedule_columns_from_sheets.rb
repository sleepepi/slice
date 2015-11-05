class RemoveScheduleColumnsFromSheets < ActiveRecord::Migration
  def up
    remove_index :sheets, :subject_schedule_id
    remove_column :sheets, :subject_schedule_id
    remove_index :sheets, :event_id
    remove_column :sheets, :event_id
  end

  def down
    add_column :sheets, :event_id, :integer
    add_index :sheets, :event_id
    add_column :sheets, :subject_schedule_id, :integer
    add_index :sheets, :subject_schedule_id
  end
end
