class AddArchivedToProjectFavorites < ActiveRecord::Migration
  def change
    add_column :project_favorites, :archived, :boolean, null: false, default: false
  end
end
