class AddVariableScopeToRandomizationScheme < ActiveRecord::Migration
  def change
    add_column :randomization_schemes, :variable_id, :integer
    add_column :randomization_schemes, :variable_value, :string
  end
end
