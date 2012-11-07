class AddSheetIdToResponses < ActiveRecord::Migration
  def change
    add_column :responses, :sheet_id, :integer
    add_index :responses, :sheet_id
  end
end
