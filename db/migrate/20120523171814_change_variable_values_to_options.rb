class ChangeVariableValuesToOptions < ActiveRecord::Migration[4.2]
  def up
    rename_column :variables, :values, :options
  end
end
