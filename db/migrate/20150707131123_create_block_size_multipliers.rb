class CreateBlockSizeMultipliers < ActiveRecord::Migration
  def change
    create_table :block_size_multipliers do |t|
      t.integer :project_id
      t.integer :user_id
      t.integer :randomization_scheme_id
      t.integer :value, null: false, default: 0
      t.integer :allocation, null: false, default: 0
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :block_size_multipliers, :project_id
    add_index :block_size_multipliers, :user_id
    add_index :block_size_multipliers, :randomization_scheme_id
    add_index :block_size_multipliers, [:randomization_scheme_id, :deleted], name: 'index_bsmultipliers_on_randomization_scheme_id_and_deleted'
  end
end
