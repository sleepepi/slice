class CreateSiteUsers < ActiveRecord::Migration
  def change
    create_table :site_users do |t|
      t.integer :project_id
      t.integer :site_id
      t.integer :user_id
      t.integer :creator_id
      t.string :invite_token
      t.string :invite_email

      t.timestamps
    end

    add_index :site_users, :invite_token, :unique => true
    add_index :site_users, :project_id
    add_index :site_users, :site_id
    add_index :site_users, :user_id
    add_index :site_users, :creator_id
  end
end
