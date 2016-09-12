class RenameColumnInProjectPreferences < ActiveRecord::Migration[5.0]
  def change
    rename_column :project_preferences, :favorite, :favorited
  end
end
