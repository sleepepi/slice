class CreateRandomizations < ActiveRecord::Migration[4.2]
  def change
    create_table :randomizations do |t|
      t.integer :project_id
      t.integer :randomization_scheme_id
      t.integer :user_id
      t.integer :list_id
      t.integer :block_group, null: false, default: 0
      t.integer :multiplier, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.integer :treatment_arm_id
      t.integer :subject_id
      t.datetime :randomized_at
      t.integer :randomized_by_id
      t.boolean :attested, null: false, default: false
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :randomizations, :project_id
    add_index :randomizations, :randomization_scheme_id
    add_index :randomizations, :user_id
    add_index :randomizations, :randomized_by_id
    add_index :randomizations, :list_id
    add_index :randomizations, :block_group
    add_index :randomizations, :position
    add_index :randomizations, :treatment_arm_id
    add_index :randomizations, :subject_id
    add_index :randomizations, :deleted
    add_index :randomizations, [:randomization_scheme_id, :deleted]
  end
end
