class AddCsvFileToDesigns < ActiveRecord::Migration
  def change
    add_column :designs, :csv_file, :string
  end
end
