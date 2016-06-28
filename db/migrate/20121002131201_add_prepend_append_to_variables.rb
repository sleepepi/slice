class AddPrependAppendToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :prepend, :string
    add_column :variables, :append, :string
  end
end
