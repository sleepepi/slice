class RemoveReadOnlyVariablesFromDesigns < ActiveRecord::Migration
  def change
    remove_column :designs, :read_only_variables, :text
  end
end
