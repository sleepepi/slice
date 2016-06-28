class AddStatusStringIndices < ActiveRecord::Migration[4.2]
  def change
    add_index :exports, :status
    add_index :subjects, :status
    add_index :users, :status
    add_index :variables, :variable_type
  end
end
