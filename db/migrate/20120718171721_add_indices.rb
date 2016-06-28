class AddIndices < ActiveRecord::Migration[4.2]
  def change
    add_index :authentications, :user_id

    add_index :designs, :project_id
    add_index :designs, :user_id

    add_index :projects, :user_id

    add_index :project_users, :project_id
    add_index :project_users, :user_id

    add_index :sheet_variables, :variable_id
    add_index :sheet_variables, :sheet_id
    add_index :sheet_variables, :user_id

    add_index :sheets, :design_id
    add_index :sheets, :project_id
    add_index :sheets, :subject_id
    add_index :sheets, :user_id
    add_index :sheets, :last_user_id

    add_index :sites, :project_id
    add_index :sites, :user_id

    add_index :subjects, :project_id
    add_index :subjects, :user_id
    add_index :subjects, :site_id

    add_index :variables, :user_id
    add_index :variables, :project_id
  end
end
