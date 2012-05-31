class AddEmailsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :emails, :text
  end
end
