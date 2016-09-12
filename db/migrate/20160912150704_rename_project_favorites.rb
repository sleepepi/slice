class RenameProjectFavorites < ActiveRecord::Migration[5.0]
  def change
    rename_table :project_favorites, :project_preferences
  end
end
