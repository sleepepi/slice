class AddEditorToSiteUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :site_users, :editor, :boolean, null: false, default: false
  end
end
