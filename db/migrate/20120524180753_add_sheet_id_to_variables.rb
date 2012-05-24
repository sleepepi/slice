class AddSheetIdToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :sheet_id, :integer
  end
end
