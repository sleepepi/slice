class AddMinMaxToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :minimum, :integer
    add_column :variables, :maximum, :integer
  end
end
