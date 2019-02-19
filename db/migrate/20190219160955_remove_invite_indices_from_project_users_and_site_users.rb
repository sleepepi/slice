class RemoveInviteIndicesFromProjectUsersAndSiteUsers < ActiveRecord::Migration[6.0]
  def up
    remove_index :project_users, :invite_token
    remove_index :project_users, :creator_id
    remove_index :site_users, :invite_token
    remove_index :site_users, :creator_id
  end

  def down
    add_index :project_users, :invite_token, unique: true
    add_index :project_users, :creator_id
    add_index :site_users, :invite_token, unique: true
    add_index :site_users, :creator_id
  end
end
