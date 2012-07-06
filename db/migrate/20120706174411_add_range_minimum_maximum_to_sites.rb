class AddRangeMinimumMaximumToSites < ActiveRecord::Migration
  def change
    add_column :sites, :code_minimum, :string
    add_column :sites, :code_maximum, :string
  end
end
