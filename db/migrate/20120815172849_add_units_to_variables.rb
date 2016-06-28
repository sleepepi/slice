class AddUnitsToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :units, :string
  end
end
