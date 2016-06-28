class AddShowSiteToDesigns < ActiveRecord::Migration[4.2]
  def change
    add_column :designs, :show_site, :boolean, null: false, default: false
  end
end
