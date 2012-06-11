class AddNameToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :name, :string
  end
end
