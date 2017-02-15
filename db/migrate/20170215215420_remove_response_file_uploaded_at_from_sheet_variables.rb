class RemoveResponseFileUploadedAtFromSheetVariables < ActiveRecord::Migration[5.0]
  def change
    remove_column :sheet_variables, :response_file_uploaded_at, :datetime
  end
end
