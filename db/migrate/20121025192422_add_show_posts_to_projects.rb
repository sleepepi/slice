class AddShowPostsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :show_posts, :boolean, null: false, default: true
    add_column :projects, :show_documents, :boolean, null: false, default: true
    add_column :projects, :show_contacts, :boolean, null: false, default: true
  end
end
