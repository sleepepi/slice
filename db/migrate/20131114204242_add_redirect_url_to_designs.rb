class AddRedirectUrlToDesigns < ActiveRecord::Migration[4.2]
  def change
    add_column :designs, :redirect_url, :string
  end
end
