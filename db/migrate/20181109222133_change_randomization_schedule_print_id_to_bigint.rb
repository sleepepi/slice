class ChangeRandomizationSchedulePrintIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :randomization_schedule_prints, :id, :bigint
  end

  def down
    change_column :randomization_schedule_prints, :id, :integer
  end
end
