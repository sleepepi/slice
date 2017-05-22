class AddFiltersToExports < ActiveRecord::Migration[5.1]
  def change
    add_column :exports, :filters, :string
  end
end
