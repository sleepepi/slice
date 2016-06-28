class RenameNameToDisplayNameForVariables < ActiveRecord::Migration[4.2]
  def change
    rename_column :variables, :name, :display_name
  end
end
