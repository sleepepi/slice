class AddUploadedFilesCountToSubject < ActiveRecord::Migration[5.0]
  def change
    add_column :subjects, :unblinded_uploaded_files_count, :integer
    add_column :subjects, :blinded_uploaded_files_count, :integer
    add_index :subjects, :unblinded_uploaded_files_count
    add_index :subjects, :blinded_uploaded_files_count
  end
end
