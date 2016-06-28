class RemoveReadOnlyVariablesFromDesigns < ActiveRecord::Migration[4.2]
  def change
    remove_column :designs, :read_only_variables, :text
  end
end
