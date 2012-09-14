class AddInviteTokenToProjectUsers < ActiveRecord::Migration
  def change
    add_column :project_users, :invite_token, :string
    add_column :project_users, :invite_email, :string
    add_column :project_users, :creator_id, :integer

    add_index :project_users, :invite_token, unique: true
    add_index :project_users, :creator_id
  end
end
