class RemoveSharedOptionsVariableIdFromVariables < ActiveRecord::Migration[4.2]
  def up
    remove_index :variables, :shared_options_variable_id
    remove_column :variables, :shared_options_variable_id
  end

  def down
    add_column :variables, :shared_options_variable_id, :integer
    add_index :variables, :shared_options_variable_id
  end
end
