class CreateMedications < ActiveRecord::Migration[6.0]
  def change
    create_table :medications do |t|
      t.bigint :project_id
      t.bigint :subject_id
      t.integer :position
      t.string :name
      t.string :start_date_fuzzy
      t.string :stop_date_fuzzy
      t.boolean :deleted, null: false, default: false
      t.timestamps

      t.index :project_id
      t.index :subject_id
      t.index :position
      t.index :start_date_fuzzy
      t.index :stop_date_fuzzy
      t.index :deleted
    end
  end
end
