class ChangeTreatmentArmIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :treatment_arms, :id, :bigint

    change_column :randomizations, :treatment_arm_id, :bigint
  end

  def down
    change_column :treatment_arms, :id, :integer

    change_column :randomizations, :treatment_arm_id, :integer
  end
end
