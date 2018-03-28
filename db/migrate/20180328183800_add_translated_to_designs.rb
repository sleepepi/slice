class AddTranslatedToDesigns < ActiveRecord::Migration[5.2]
  def change
    add_column :designs, :translated, :boolean, null: false, default: false
  end
end
