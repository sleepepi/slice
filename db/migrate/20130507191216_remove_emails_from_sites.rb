class RemoveEmailsFromSites < ActiveRecord::Migration
  def up
    remove_column :sites, :emails
  end

  def down
    add_column :sites, :emails, :text
  end
end
