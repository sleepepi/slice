class AddSoftMaxMinToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :date_soft_maximum, :date
    add_column :variables, :date_soft_minimum, :date
    add_column :variables, :soft_maximum, :integer
    add_column :variables, :soft_minimum, :integer
  end
end
