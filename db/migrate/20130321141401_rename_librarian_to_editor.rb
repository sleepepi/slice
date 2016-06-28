class RenameLibrarianToEditor < ActiveRecord::Migration[4.2]
  def change
    rename_column :project_users, :librarian, :editor
  end
end
