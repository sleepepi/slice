class ChangeVariableValuesToOptions < ActiveRecord::Migration
  def up
    rename_column :variables, :values, :options
  end
end
