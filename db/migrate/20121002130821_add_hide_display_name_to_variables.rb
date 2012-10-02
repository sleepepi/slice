class AddHideDisplayNameToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :hide_display_name, :boolean, null: false, default: false
  end
end
