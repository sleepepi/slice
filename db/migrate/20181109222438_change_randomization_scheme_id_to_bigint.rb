class ChangeRandomizationSchemeIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :randomization_schemes, :id, :bigint

    change_column :block_size_multipliers, :randomization_scheme_id, :bigint
    change_column :expected_randomizations, :randomization_scheme_id, :bigint
    change_column :list_options, :randomization_scheme_id, :bigint
    change_column :lists, :randomization_scheme_id, :bigint
    change_column :randomization_characteristics, :randomization_scheme_id, :bigint
    change_column :randomization_scheme_tasks, :randomization_scheme_id, :bigint
    change_column :randomizations, :randomization_scheme_id, :bigint
    change_column :stratification_factor_options, :randomization_scheme_id, :bigint
    change_column :stratification_factors, :randomization_scheme_id, :bigint
    change_column :treatment_arms, :randomization_scheme_id, :bigint
  end

  def down
    change_column :randomization_schemes, :id, :integer

    change_column :block_size_multipliers, :randomization_scheme_id, :integer
    change_column :expected_randomizations, :randomization_scheme_id, :integer
    change_column :list_options, :randomization_scheme_id, :integer
    change_column :lists, :randomization_scheme_id, :integer
    change_column :randomization_characteristics, :randomization_scheme_id, :integer
    change_column :randomization_scheme_tasks, :randomization_scheme_id, :integer
    change_column :randomizations, :randomization_scheme_id, :integer
    change_column :stratification_factor_options, :randomization_scheme_id, :integer
    change_column :stratification_factors, :randomization_scheme_id, :integer
    change_column :treatment_arms, :randomization_scheme_id, :integer
  end
end
