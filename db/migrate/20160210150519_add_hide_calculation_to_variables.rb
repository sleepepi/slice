class AddHideCalculationToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :hide_calculation, :boolean, null: false, default: false
  end
end
