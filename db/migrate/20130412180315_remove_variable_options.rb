class RemoveVariableOptions < ActiveRecord::Migration
  def up
    remove_column :variables, :options
  end

  def down
    add_column :variables, :options, :text
  end
end
