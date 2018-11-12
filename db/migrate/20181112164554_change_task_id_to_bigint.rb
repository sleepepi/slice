class ChangeTaskIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :tasks, :id, :bigint

    change_column :randomization_tasks, :task_id, :bigint
  end

  def down
    change_column :tasks, :id, :integer

    change_column :randomization_tasks, :task_id, :integer
  end
end
