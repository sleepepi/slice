class ChangeProjectIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :projects, :id, :bigint

    change_column :adverse_event_comments, :project_id, :bigint
    change_column :adverse_event_files, :project_id, :bigint
    change_column :adverse_events, :project_id, :bigint
    change_column :block_size_multipliers, :project_id, :bigint
    change_column :categories, :project_id, :bigint
    change_column :check_filter_values, :project_id, :bigint
    change_column :check_filters, :project_id, :bigint
    change_column :checks, :project_id, :bigint
    change_column :designs, :project_id, :bigint
    change_column :domains, :project_id, :bigint
    change_column :engine_runs, :project_id, :bigint
    change_column :events, :project_id, :bigint
    change_column :exports, :project_id, :bigint
    change_column :grid_variables, :project_id, :bigint
    change_column :handoffs, :project_id, :bigint
    change_column :list_options, :project_id, :bigint
    change_column :lists, :project_id, :bigint
    change_column :notifications, :project_id, :bigint
    change_column :project_preferences, :project_id, :bigint
    change_column :project_users, :project_id, :bigint
    change_column :randomization_characteristics, :project_id, :bigint
    change_column :randomization_schemes, :project_id, :bigint
    change_column :randomizations, :project_id, :bigint
    change_column :sections, :project_id, :bigint
    change_column :sheet_errors, :project_id, :bigint
    change_column :sheet_transaction_audits, :project_id, :bigint
    change_column :sheet_transactions, :project_id, :bigint
    change_column :sheets, :project_id, :bigint
    change_column :site_users, :project_id, :bigint
    change_column :sites, :project_id, :bigint
    change_column :stratification_factor_options, :project_id, :bigint
    change_column :stratification_factors, :project_id, :bigint
    change_column :subjects, :project_id, :bigint
    change_column :tasks, :project_id, :bigint
    change_column :treatment_arms, :project_id, :bigint
    change_column :variables, :project_id, :bigint
  end

  def down
    change_column :projects, :id, :integer

    change_column :adverse_event_comments, :project_id, :integer
    change_column :adverse_event_files, :project_id, :integer
    change_column :adverse_events, :project_id, :integer
    change_column :block_size_multipliers, :project_id, :integer
    change_column :categories, :project_id, :integer
    change_column :check_filter_values, :project_id, :integer
    change_column :check_filters, :project_id, :integer
    change_column :checks, :project_id, :integer
    change_column :designs, :project_id, :integer
    change_column :domains, :project_id, :integer
    change_column :engine_runs, :project_id, :integer
    change_column :events, :project_id, :integer
    change_column :exports, :project_id, :integer
    change_column :grid_variables, :project_id, :integer
    change_column :handoffs, :project_id, :integer
    change_column :list_options, :project_id, :integer
    change_column :lists, :project_id, :integer
    change_column :notifications, :project_id, :integer
    change_column :project_preferences, :project_id, :integer
    change_column :project_users, :project_id, :integer
    change_column :randomization_characteristics, :project_id, :integer
    change_column :randomization_schemes, :project_id, :integer
    change_column :randomizations, :project_id, :integer
    change_column :sections, :project_id, :integer
    change_column :sheet_errors, :project_id, :integer
    change_column :sheet_transaction_audits, :project_id, :integer
    change_column :sheet_transactions, :project_id, :integer
    change_column :sheets, :project_id, :integer
    change_column :site_users, :project_id, :integer
    change_column :sites, :project_id, :integer
    change_column :stratification_factor_options, :project_id, :integer
    change_column :stratification_factors, :project_id, :integer
    change_column :subjects, :project_id, :integer
    change_column :tasks, :project_id, :integer
    change_column :treatment_arms, :project_id, :integer
    change_column :variables, :project_id, :integer
  end
end
