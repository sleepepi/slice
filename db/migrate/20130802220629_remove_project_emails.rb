class RemoveProjectEmails < ActiveRecord::Migration
  def change
    remove_column :projects, :emails, :text
  end
end
