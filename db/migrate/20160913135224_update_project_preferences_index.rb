class UpdateProjectPreferencesIndex < ActiveRecord::Migration[5.0]
  def change
    remove_index :project_preferences, :user_id
    remove_index :project_preferences, :project_id
    add_index :project_preferences, [:user_id, :project_id], unique: true
  end
end
