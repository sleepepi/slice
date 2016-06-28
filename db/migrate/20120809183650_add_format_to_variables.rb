class AddFormatToVariables < ActiveRecord::Migration[4.2]
  def change
    add_column :variables, :format, :string
  end
end
