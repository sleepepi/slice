class AddRangeMinimumMaximumToSites < ActiveRecord::Migration[4.2]
  def change
    add_column :sites, :code_minimum, :string
    add_column :sites, :code_maximum, :string
  end
end
