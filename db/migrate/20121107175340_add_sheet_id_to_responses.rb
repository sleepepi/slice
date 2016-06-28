class AddSheetIdToResponses < ActiveRecord::Migration[4.2]
  def change
    add_column :responses, :sheet_id, :integer
    add_index :responses, :sheet_id
  end
end
