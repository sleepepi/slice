class AddCsvFileToDesigns < ActiveRecord::Migration[4.2]
  def change
    add_column :designs, :csv_file, :string
  end
end
