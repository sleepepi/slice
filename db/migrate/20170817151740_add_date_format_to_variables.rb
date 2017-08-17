class AddDateFormatToVariables < ActiveRecord::Migration[5.1]
  def change
    add_column :variables, :date_format, :string, null: false, default: "mm/dd/yyyy"
  end
end
