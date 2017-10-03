class RenameFormatToCalculatedFormatForVariables < ActiveRecord::Migration[5.1]
  def change
    rename_column :variables, :format, :calculated_format
  end
end
