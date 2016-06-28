class RemoveProjectEmails < ActiveRecord::Migration[4.2]
  def change
    remove_column :projects, :emails, :text
  end
end
