class RenameMinMaxHardMinHardMax < ActiveRecord::Migration[4.2]
  def change
    rename_column :variables, :minimum, :hard_minimum
    rename_column :variables, :maximum, :hard_maximum
  end
end
