class ChangeVariableValuesToOptions < ActiveRecord::Migration[4.2]
  def change
    rename_column :variables, :values, :options
  end
end
