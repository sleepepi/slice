class RemoveStatusFromSubjectEvents < ActiveRecord::Migration[4.2]
  def up
    remove_column :subject_events, :status
  end

  def down
    add_column :subject_events, :status, :string, null: false, default: 'scheduled'
  end
end
