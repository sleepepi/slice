class CreateMedicationVariables < ActiveRecord::Migration[6.0]
  def change
    create_table :medication_variables do |t|
      t.bigint :project_id
      t.string :name
      t.text :autocomplete_values
      t.boolean :deleted, null: false, default: false
      t.timestamps

      t.index :project_id
      t.index :deleted
    end
  end
end
