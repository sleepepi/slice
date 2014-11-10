class ChangeVariablesCalculationToText < ActiveRecord::Migration
  def up
    change_column :variables, :calculation, :text
  end

  def down
    change_column :variables, :calculation, :string
  end
end
