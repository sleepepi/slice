class AddNameToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :name, :string
  end
end
