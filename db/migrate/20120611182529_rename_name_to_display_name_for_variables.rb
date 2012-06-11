class RenameNameToDisplayNameForVariables < ActiveRecord::Migration
  def change
    rename_column :variables, :name, :display_name
  end
end
