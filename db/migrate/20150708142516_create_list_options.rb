class CreateListOptions < ActiveRecord::Migration[4.2]
  def change
    create_table :list_options do |t|
      t.integer :project_id
      t.integer :randomization_scheme_id
      t.integer :list_id
      t.integer :option_id

      t.timestamps null: false
    end

    add_index :list_options, :project_id
    add_index :list_options, :randomization_scheme_id
    add_index :list_options, :list_id
    add_index :list_options, :option_id
    add_index :list_options, [:list_id, :option_id]
  end
end
