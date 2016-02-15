class CreateRandomizationTasks < ActiveRecord::Migration
  def change
    create_table :randomization_tasks do |t|
      t.integer :randomization_id
      t.integer :task_id

      t.timestamps null: false
    end

    add_index :randomization_tasks, :randomization_id
    add_index :randomization_tasks, :task_id
  end
end
