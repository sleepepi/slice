class AddOptionsToDesigns < ActiveRecord::Migration
  def change
    add_column :designs, :options, :text
  end
end
