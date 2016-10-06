class RemoveEmailNotificationsFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :email_notifications, :text
  end
end
