class AddFileUploaderToSheetVariables < ActiveRecord::Migration
  def change
    add_column :sheet_variables, :response_file, :string
    add_column :sheet_variables, :response_file_uploaded_at, :datetime
  end
end
