class RemoveHideDisplayNameFromVariables < ActiveRecord::Migration[4.2]
  def up
    remove_column :variables, :hide_display_name
  end

  def down
    add_column :variables, :hide_display_name, :boolean, null: false, default: false
  end
end
