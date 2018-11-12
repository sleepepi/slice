class ChangeForeignKeysToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :designs, :updater_id, :bigint
    change_column :event_designs, :conditional_event_id, :bigint
    change_column :event_designs, :conditional_design_id, :bigint
    change_column :event_designs, :conditional_variable_id, :bigint
    change_column :grid_variables, :parent_variable_id, :bigint
    change_column :grid_variables, :child_variable_id, :bigint
    change_column :list_options, :option_id, :bigint
    change_column :project_users, :creator_id, :bigint
    change_column :randomizations, :randomized_by_id, :bigint
    change_column :sheets, :last_user_id, :bigint
    change_column :site_users, :creator_id, :bigint
    change_column :variables, :updater_id, :bigint
  end

  def down
    change_column :designs, :updater_id, :integer
    change_column :event_designs, :conditional_event_id, :integer
    change_column :event_designs, :conditional_design_id, :integer
    change_column :event_designs, :conditional_variable_id, :integer
    change_column :grid_variables, :parent_variable_id, :integer
    change_column :grid_variables, :child_variable_id, :integer
    change_column :list_options, :option_id, :integer
    change_column :project_users, :creator_id, :integer
    change_column :randomizations, :randomized_by_id, :integer
    change_column :sheets, :last_user_id, :integer
    change_column :site_users, :creator_id, :integer
    change_column :variables, :updater_id, :integer
  end
end
