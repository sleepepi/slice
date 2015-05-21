class AddIndexesToSubjectEvents < ActiveRecord::Migration
  def change
    add_index :subject_events, :subject_id
    add_index :subject_events, :event_id
  end
end
