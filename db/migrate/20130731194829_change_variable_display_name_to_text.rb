class ChangeVariableDisplayNameToText < ActiveRecord::Migration
  def up
    change_column :variables, :display_name, :text
  end

  def down
    change_column :variables, :display_name, :string
  end
end
