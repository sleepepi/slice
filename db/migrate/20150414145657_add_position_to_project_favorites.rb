class AddPositionToProjectFavorites < ActiveRecord::Migration[4.2]
  def change
    add_column :project_favorites, :position, :integer, null: false, default: 0
  end
end
