class CreateTranslations < ActiveRecord::Migration[5.2]
  def change
    create_table :translations do |t|
      t.integer :translatable_id
      t.string :translatable_type
      t.string :translatable_attribute
      t.string :locale
      t.text :translation
      t.timestamps
      t.index [:translatable_id, :translatable_type, :translatable_attribute, :locale], unique: true, name: "index_translation"
    end
  end
end
