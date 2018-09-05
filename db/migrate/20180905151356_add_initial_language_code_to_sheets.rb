class AddInitialLanguageCodeToSheets < ActiveRecord::Migration[5.2]
  def change
    add_column :sheets, :initial_language_code, :string
  end
end
