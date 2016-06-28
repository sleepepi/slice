class CreateSubjectEvents < ActiveRecord::Migration[4.2]
  def change
    create_table :subject_events do |t|
      t.integer :subject_id
      t.integer :event_id
      t.string :status, null: false, default: 'scheduled'
      t.date :event_date

      t.timestamps null: false
    end
  end
end
