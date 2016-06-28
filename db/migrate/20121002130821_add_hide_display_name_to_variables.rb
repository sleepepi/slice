class AddHideDisplayNameToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :hide_display_name, :boolean, null: false, default: false
  end
end
