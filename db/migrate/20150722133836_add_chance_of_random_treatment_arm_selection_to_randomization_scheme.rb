class AddChanceOfRandomTreatmentArmSelectionToRandomizationScheme < ActiveRecord::Migration[4.2]
  def change
    add_column :randomization_schemes, :chance_of_random_treatment_arm_selection, :integer, null: false, default: 30
  end
end
