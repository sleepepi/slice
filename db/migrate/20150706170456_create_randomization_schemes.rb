class CreateRandomizationSchemes < ActiveRecord::Migration[4.2]
  def change
    create_table :randomization_schemes do |t|
      t.string :name
      t.text :description
      t.integer :project_id
      t.integer :user_id
      t.boolean :published, null: false, default: false
      t.integer :randomization_goal, null: false, default: 0
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :randomization_schemes, :project_id
    add_index :randomization_schemes, :user_id
    add_index :randomization_schemes, :deleted
    add_index :randomization_schemes, [:project_id, :deleted]
  end
end
