class RemoveImportColumnsFromDesigns < ActiveRecord::Migration[6.0]
  def change
    remove_column :designs, :import_started_at, :datetime
    remove_column :designs, :import_ended_at, :datetime
    remove_column :designs, :rows_imported, :integer, null: false, default: 0
    remove_column :designs, :total_rows, :integer, null: false, default: 0
    remove_column :designs, :csv_file, :string
  end
end
