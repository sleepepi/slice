class AddVariablesCountIndex < ActiveRecord::Migration[5.0]
  def change
    add_index :domains, :variables_count
  end
end
