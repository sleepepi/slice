class RemoveResponseFromVariables < ActiveRecord::Migration
  def up
    remove_column :variables, :response
  end

  def down
    add_column :variables, :response, :text
  end
end
