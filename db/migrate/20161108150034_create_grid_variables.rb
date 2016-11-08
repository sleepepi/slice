class CreateGridVariables < ActiveRecord::Migration[5.0]
  def change
    create_table :grid_variables do |t|
      t.integer :project_id
      t.integer :parent_variable_id
      t.integer :child_variable_id
      t.integer :position
      t.timestamps
      t.index :project_id
      t.index [:parent_variable_id, :child_variable_id], name: 'parent_child_variable_index', unique: true
      t.index :position
    end
  end
end
