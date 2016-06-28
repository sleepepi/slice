class CreateDesignsVariables < ActiveRecord::Migration[4.2]
  def change
    create_table :designs_variables, id: false do |t|
      t.integer :design_id
      t.integer :variable_id
    end
  end
end
