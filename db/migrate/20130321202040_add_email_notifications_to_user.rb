class AddEmailNotificationsToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_notifications, :text
  end
end
