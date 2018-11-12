class ChangeVariableIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :variables, :id, :bigint

    change_column :check_filters, :variable_id, :bigint
    change_column :design_options, :variable_id, :bigint
    change_column :grids, :variable_id, :bigint
    change_column :randomization_schemes, :variable_id, :bigint
    change_column :responses, :variable_id, :bigint
    change_column :sheet_variables, :variable_id, :bigint
  end

  def down
    change_column :variables, :id, :integer

    change_column :check_filters, :variable_id, :integer
    change_column :design_options, :variable_id, :integer
    change_column :grids, :variable_id, :integer
    change_column :randomization_schemes, :variable_id, :integer
    change_column :responses, :variable_id, :integer
    change_column :sheet_variables, :variable_id, :integer
  end
end
