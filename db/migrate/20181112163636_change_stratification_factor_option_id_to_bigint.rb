class ChangeStratificationFactorOptionIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :stratification_factor_options, :id, :bigint

    change_column :randomization_characteristics, :stratification_factor_option_id, :bigint
  end

  def down
    change_column :stratification_factor_options, :id, :integer

    change_column :randomization_characteristics, :stratification_factor_option_id, :integer
  end
end
