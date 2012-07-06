class AddDateHardMaxMinToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :date_hard_maximum, :date
    add_column :variables, :date_hard_minimum, :date
  end
end
