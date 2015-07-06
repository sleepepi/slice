class CreateTreatmentArms < ActiveRecord::Migration
  def change
    create_table :treatment_arms do |t|
      t.string :name
      t.integer :project_id
      t.integer :randomization_scheme_id
      t.integer :allocation, null: false, default: 0
      t.integer :user_id
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :treatment_arms, :project_id
    add_index :treatment_arms, :randomization_scheme_id
    add_index :treatment_arms, :user_id
    add_index :treatment_arms, :deleted
    add_index :treatment_arms, [:randomization_scheme_id, :deleted]
  end
end
