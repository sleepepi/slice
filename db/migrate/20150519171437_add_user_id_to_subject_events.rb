class AddUserIdToSubjectEvents < ActiveRecord::Migration[4.2]
  def up
    add_column :subject_events, :user_id, :integer
    add_index :subject_events, :user_id
  end

  def down
    remove_index :subject_events, :user_id
    remove_column :subject_events, :user_id
  end
end
