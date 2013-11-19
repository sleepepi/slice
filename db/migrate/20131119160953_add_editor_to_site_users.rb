class AddEditorToSiteUsers < ActiveRecord::Migration
  def change
    add_column :site_users, :editor, :boolean, null: false, default: false
  end
end
