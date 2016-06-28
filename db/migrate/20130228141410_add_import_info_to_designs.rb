class AddImportInfoToDesigns < ActiveRecord::Migration[4.2]
  def change
    add_column :designs, :rows_imported, :integer, null: false, default: 0
    add_column :designs, :total_rows, :integer, null: false, default: 0
  end
end
