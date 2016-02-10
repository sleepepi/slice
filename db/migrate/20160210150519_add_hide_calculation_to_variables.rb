class AddHideCalculationToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :hide_calculation, :boolean, null: false, default: false
  end
end
