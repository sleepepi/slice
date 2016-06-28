class RemoveResponseFromVariables < ActiveRecord::Migration[4.2]
  def up
    remove_column :variables, :response
  end

  def down
    add_column :variables, :response, :text
  end
end
