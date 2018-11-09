class ChangeRandomizationTaskIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :randomization_tasks, :id, :bigint
  end

  def down
    change_column :randomization_tasks, :id, :integer
  end
end
