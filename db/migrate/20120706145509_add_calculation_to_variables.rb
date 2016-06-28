class AddCalculationToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :calculation, :string
  end
end
