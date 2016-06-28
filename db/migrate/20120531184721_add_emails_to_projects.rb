class AddEmailsToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :emails, :text
  end
end
