class AddCalculationToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :calculation, :string
  end
end
