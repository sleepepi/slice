class AddVariableScopeToRandomizationScheme < ActiveRecord::Migration[4.2]
  def change
    add_column :randomization_schemes, :variable_id, :integer
    add_column :randomization_schemes, :variable_value, :string
  end
end
