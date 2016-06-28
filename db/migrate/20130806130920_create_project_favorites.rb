class CreateProjectFavorites < ActiveRecord::Migration[4.2]
  def change
    create_table :project_favorites do |t|
      t.integer :project_id
      t.integer :user_id
      t.boolean :favorite, default: false, null: false

      t.timestamps
    end

    add_index :project_favorites, :project_id
    add_index :project_favorites, :user_id
  end
end
