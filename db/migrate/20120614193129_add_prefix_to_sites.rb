class AddPrefixToSites < ActiveRecord::Migration
  def change
    add_column :sites, :prefix, :string, null: false, default: ''
  end
end
