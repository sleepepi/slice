class ChangeVariablesCalculationToText < ActiveRecord::Migration[4.2]
  def up
    change_column :variables, :calculation, :text
  end

  def down
    change_column :variables, :calculation, :string
  end
end
