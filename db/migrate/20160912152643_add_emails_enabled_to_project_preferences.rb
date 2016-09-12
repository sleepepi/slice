class AddEmailsEnabledToProjectPreferences < ActiveRecord::Migration[5.0]
  def change
    add_column :project_preferences, :emails_enabled, :boolean, null: false, default: true
    add_index :project_preferences, :emails_enabled
  end
end
