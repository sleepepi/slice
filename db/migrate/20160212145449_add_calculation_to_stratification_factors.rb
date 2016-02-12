class AddCalculationToStratificationFactors < ActiveRecord::Migration
  def change
    add_column :stratification_factors, :calculation, :text
  end
end
