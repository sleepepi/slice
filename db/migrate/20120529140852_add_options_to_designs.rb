class AddOptionsToDesigns < ActiveRecord::Migration[4.2]
  def change
    add_column :designs, :options, :text
  end
end
