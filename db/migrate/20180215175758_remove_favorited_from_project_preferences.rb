class RemoveFavoritedFromProjectPreferences < ActiveRecord::Migration[5.2]
  def change
    remove_column :project_preferences, :favorited, :boolean, null: false, default: false
  end
end
