class AddArchivedToContacts < ActiveRecord::Migration[4.2]
  def change
    add_column :contacts, :archived, :boolean, null: false, default: false
  end
end
