class AddSharedOptionsVariableIdToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :shared_options_variable_id, :integer
    add_index :variables, :shared_options_variable_id
  end
end
