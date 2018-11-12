class ChangeSubjectIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :subjects, :id, :bigint

    change_column :adverse_events, :subject_id, :bigint
    change_column :randomizations, :subject_id, :bigint
    change_column :sheets, :subject_id, :bigint
    change_column :subject_events, :subject_id, :bigint
  end

  def down
    change_column :subjects, :id, :integer

    change_column :adverse_events, :subject_id, :integer
    change_column :randomizations, :subject_id, :integer
    change_column :sheets, :subject_id, :integer
    change_column :subject_events, :subject_id, :integer
  end
end
