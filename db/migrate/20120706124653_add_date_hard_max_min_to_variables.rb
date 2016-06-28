class AddDateHardMaxMinToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :date_hard_maximum, :date
    add_column :variables, :date_hard_minimum, :date
  end
end
