class CreateSubjectSchedules < ActiveRecord::Migration[4.2]
  def change
    create_table :subject_schedules do |t|
      t.integer :subject_id
      t.integer :schedule_id
      t.date :initial_due_date

      t.timestamps
    end
  end
end
