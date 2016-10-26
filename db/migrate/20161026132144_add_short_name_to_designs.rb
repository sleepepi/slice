class AddShortNameToDesigns < ActiveRecord::Migration[5.0]
  def change
    add_column :designs, :short_name, :string
  end
end
