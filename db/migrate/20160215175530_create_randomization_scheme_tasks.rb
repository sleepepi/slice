class CreateRandomizationSchemeTasks < ActiveRecord::Migration[4.2]
  def change
    create_table :randomization_scheme_tasks do |t|
      t.integer :randomization_scheme_id
      t.text :description
      t.integer :offset, null: false, default: 0
      t.string :offset_units
      t.integer :window, null: false, default: 0
      t.string :window_units
      t.integer :position, null: false, default: 0

      t.timestamps null: false
    end

    add_index :randomization_scheme_tasks, :randomization_scheme_id
    add_index :randomization_scheme_tasks, :position
  end
end
