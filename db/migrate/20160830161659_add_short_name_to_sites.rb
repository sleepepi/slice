class AddShortNameToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :short_name, :string
  end
end
