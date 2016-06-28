class RemoveSheetIdFromVariables < ActiveRecord::Migration[4.2]
  def up
    remove_column :variables, :sheet_id
  end

  def down
    add_column :variables, :sheet_id, :integer
  end
end
