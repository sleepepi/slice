class ChangeSubjectEventIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :subject_events, :id, :bigint

    change_column :handoffs, :subject_event_id, :bigint
    change_column :sheets, :subject_event_id, :bigint
  end

  def down
    change_column :subject_events, :id, :integer

    change_column :handoffs, :subject_event_id, :integer
    change_column :sheets, :subject_event_id, :integer
  end
end
