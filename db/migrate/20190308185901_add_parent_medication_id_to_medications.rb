class AddParentMedicationIdToMedications < ActiveRecord::Migration[6.0]
  def change
    add_column :medications, :parent_medication_id, :bigint
    add_index :medications, :parent_medication_id
  end
end
