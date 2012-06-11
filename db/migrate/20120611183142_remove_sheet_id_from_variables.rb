class RemoveSheetIdFromVariables < ActiveRecord::Migration
  def up
    remove_column :variables, :sheet_id
  end

  def down
    add_column :variables, :sheet_id, :integer
  end
end
