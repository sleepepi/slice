class RemoveInviteColumnsFromProjectUsersAndSiteUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :project_users, :invite_token, :string
    remove_column :project_users, :invite_email, :string
    remove_column :project_users, :creator_id, :bigint

    remove_column :site_users, :invite_token, :string
    remove_column :site_users, :invite_email, :string
    remove_column :site_users, :creator_id, :bigint
  end
end
