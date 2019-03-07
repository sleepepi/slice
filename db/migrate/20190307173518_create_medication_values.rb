class CreateMedicationValues < ActiveRecord::Migration[6.0]
  def change
    create_table :medication_values do |t|
      t.bigint :project_id
      t.bigint :medication_variable_id
      t.bigint :subject_id
      t.bigint :medication_id
      t.string :value
      t.timestamps

      t.index :project_id
      t.index :subject_id
      t.index [:medication_variable_id, :medication_id], unique: true, name: "index_med_values_on_medication_and_med_variable"
    end
  end
end
