class AddArchivedToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :archived, :boolean, null: false, default: false
  end
end
