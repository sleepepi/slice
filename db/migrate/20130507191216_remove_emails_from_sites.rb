class RemoveEmailsFromSites < ActiveRecord::Migration[4.2]
  def up
    remove_column :sites, :emails
  end

  def down
    add_column :sites, :emails, :text
  end
end
