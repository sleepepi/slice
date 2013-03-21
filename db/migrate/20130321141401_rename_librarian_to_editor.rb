class RenameLibrarianToEditor < ActiveRecord::Migration
  def change
    rename_column :project_users, :librarian, :editor
  end
end
