class AddPrefixToSites < ActiveRecord::Migration[4.2]
  def change
    add_column :sites, :prefix, :string, null: false, default: ''
  end
end
