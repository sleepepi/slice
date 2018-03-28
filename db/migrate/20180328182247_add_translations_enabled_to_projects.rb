class AddTranslationsEnabledToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :translations_enabled, :boolean, null: false, default: false
  end
end
