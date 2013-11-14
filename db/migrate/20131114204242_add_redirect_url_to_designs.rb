class AddRedirectUrlToDesigns < ActiveRecord::Migration
  def change
    add_column :designs, :redirect_url, :string
  end
end
