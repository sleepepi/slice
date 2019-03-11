class AddPositionToMedicationVariables < ActiveRecord::Migration[6.0]
  def change
    add_column :medication_variables, :position, :integer
  end
end
