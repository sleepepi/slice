class AddPrependAppendToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :prepend, :string
    add_column :variables, :append, :string
  end
end
