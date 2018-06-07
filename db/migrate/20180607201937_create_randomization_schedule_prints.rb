class CreateRandomizationSchedulePrints < ActiveRecord::Migration[5.2]
  def change
    create_table :randomization_schedule_prints do |t|
      t.integer :randomization_id
      t.string :language
      t.boolean :outdated, null: false, default: true
      t.string :file
      t.bigint :file_size, null: false, default: 0
      t.timestamps
      t.index [:randomization_id, :language], unique: true, name: "idx_randomization_schedules_prints"
    end
  end
end
