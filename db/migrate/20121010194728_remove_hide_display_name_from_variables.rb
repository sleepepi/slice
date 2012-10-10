class RemoveHideDisplayNameFromVariables < ActiveRecord::Migration
  def up
    remove_column :variables, :hide_display_name
  end

  def down
    add_column :variables, :hide_display_name, :boolean, null: false, default: false
  end
end
