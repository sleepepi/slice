class AddCustomTreatmentNameToRandomizations < ActiveRecord::Migration[5.2]
  def change
    add_column :randomizations, :custom_treatment_name, :string
  end
end
