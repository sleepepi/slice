class AddUploadedFilesCountToSheets < ActiveRecord::Migration[5.1]
  def change
    add_column :sheets, :uploaded_files_count, :integer
    add_index :sheets, :uploaded_files_count
  end
end
