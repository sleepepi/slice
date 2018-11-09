class ChangeRandomizationIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :randomizations, :id, :bigint

    change_column :randomization_characteristics, :randomization_id, :bigint
    change_column :randomization_schedule_prints, :randomization_id, :bigint
    change_column :randomization_tasks, :randomization_id, :bigint
  end

  def down
    change_column :randomizations, :id, :integer

    change_column :randomization_characteristics, :randomization_id, :integer
    change_column :randomization_schedule_prints, :randomization_id, :integer
    change_column :randomization_tasks, :randomization_id, :integer
  end
end
