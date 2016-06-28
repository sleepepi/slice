class AddReadOnlyVariablesToDesigns < ActiveRecord::Migration[4.2]
  def change
    add_column :designs, :read_only_variables, :text
  end
end
