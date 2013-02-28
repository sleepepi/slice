class AddImportInfoToDesigns < ActiveRecord::Migration
  def change
    add_column :designs, :rows_imported, :integer, null: false, default: 0
    add_column :designs, :total_rows, :integer, null: false, default: 0
  end
end
