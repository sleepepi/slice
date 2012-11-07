class AddSheetIdToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :sheet_id, :integer
    add_index :variables, :sheet_id
  end
end
