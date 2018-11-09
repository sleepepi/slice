class ChangeAdverseEventIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :adverse_events, :id, :bigint

    change_column :adverse_event_comments, :adverse_event_id, :bigint
    change_column :adverse_event_files, :adverse_event_id, :bigint
    change_column :adverse_event_reviews, :adverse_event_id, :bigint
    change_column :adverse_event_users, :adverse_event_id, :bigint
    change_column :notifications, :adverse_event_id, :bigint
    change_column :sheets, :adverse_event_id, :bigint
  end

  def down
    change_column :adverse_events, :id, :integer

    change_column :adverse_event_comments, :adverse_event_id, :integer
    change_column :adverse_event_files, :adverse_event_id, :integer
    change_column :adverse_event_reviews, :adverse_event_id, :integer
    change_column :adverse_event_users, :adverse_event_id, :integer
    change_column :notifications, :adverse_event_id, :integer
    change_column :sheets, :adverse_event_id, :integer
  end
end
