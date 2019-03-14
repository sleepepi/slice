class CreateMedicationTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :medication_templates do |t|
      t.bigint :project_id
      t.string :name
      t.boolean :mark_for_deletion, null: false, default: false
      t.timestamps

      t.index [:project_id, :name], unique: true
      t.index :mark_for_deletion
    end
  end
end
