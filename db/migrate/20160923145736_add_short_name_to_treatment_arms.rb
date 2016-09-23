class AddShortNameToTreatmentArms < ActiveRecord::Migration[5.0]
  def change
    add_column :treatment_arms, :short_name, :string
  end
end
