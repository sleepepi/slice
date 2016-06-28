class AddArchivedToProjectFavorites < ActiveRecord::Migration[4.2]
  def change
    add_column :project_favorites, :archived, :boolean, null: false, default: false
  end
end
