class AddDisableAllEmailsToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :disable_all_emails, :boolean, default: false
  end
end
