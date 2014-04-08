class AddReadOnlyVariablesToDesigns < ActiveRecord::Migration
  def change
    add_column :designs, :read_only_variables, :text
  end
end
