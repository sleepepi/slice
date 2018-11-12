class ChangeStratificationFactorIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :stratification_factors, :id, :bigint

    change_column :randomization_characteristics, :stratification_factor_id, :bigint
    change_column :stratification_factor_options, :stratification_factor_id, :bigint
  end

  def down
    change_column :stratification_factors, :id, :integer

    change_column :randomization_characteristics, :stratification_factor_id, :integer
    change_column :stratification_factor_options, :stratification_factor_id, :integer
  end
end
