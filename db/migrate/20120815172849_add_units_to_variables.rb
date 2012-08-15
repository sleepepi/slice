class AddUnitsToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :units, :string
  end
end
