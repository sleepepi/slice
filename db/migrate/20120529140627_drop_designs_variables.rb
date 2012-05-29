class DropDesignsVariables < ActiveRecord::Migration
  def up
    drop_table :designs_variables
  end

  def down
    create_table :designs_variables, id: false do |t|
      t.integer :design_id
      t.integer :variable_id
    end
  end
end
