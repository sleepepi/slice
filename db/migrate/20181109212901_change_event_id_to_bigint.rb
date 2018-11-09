class ChangeEventIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :events, :id, :bigint

    change_column :event_designs, :event_id, :bigint
    change_column :subject_events, :event_id, :bigint
  end

  def down
    change_column :events, :id, :integer

    change_column :event_designs, :event_id, :integer
    change_column :subject_events, :event_id, :integer
  end
end
