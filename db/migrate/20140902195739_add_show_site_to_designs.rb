class AddShowSiteToDesigns < ActiveRecord::Migration
  def change
    add_column :designs, :show_site, :boolean, null: false, default: false
  end
end
