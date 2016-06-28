class AddEmailNotificationsToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :email_notifications, :text
  end
end
