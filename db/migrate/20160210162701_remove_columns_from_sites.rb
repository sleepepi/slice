class RemoveColumnsFromSites < ActiveRecord::Migration[4.2]
  def change
    remove_column :sites, :prefix, :string, null: false, default: ''
    remove_column :sites, :code_minimum, :string
    remove_column :sites, :code_maximum, :string
  end
end
