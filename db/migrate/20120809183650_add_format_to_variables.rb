class AddFormatToVariables < ActiveRecord::Migration
  def change
    add_column :variables, :format, :string
  end
end
