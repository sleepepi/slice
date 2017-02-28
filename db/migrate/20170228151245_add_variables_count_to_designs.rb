class AddVariablesCountToDesigns < ActiveRecord::Migration[5.0]
  def change
    add_column :designs, :variables_count, :integer, null: false, default: 0
    add_index :designs, :variables_count
  end
end
