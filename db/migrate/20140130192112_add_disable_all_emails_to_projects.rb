class AddDisableAllEmailsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :disable_all_emails, :boolean, default: false
  end
end
