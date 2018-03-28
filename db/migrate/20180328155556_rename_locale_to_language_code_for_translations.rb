class RenameLocaleToLanguageCodeForTranslations < ActiveRecord::Migration[5.2]
  def change
    rename_column :translations, :locale, :language_code
  end
end
