class AddSoftMaxMinToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :date_soft_maximum, :date
    add_column :variables, :date_soft_minimum, :date
    add_column :variables, :soft_maximum, :integer
    add_column :variables, :soft_minimum, :integer
  end
end
