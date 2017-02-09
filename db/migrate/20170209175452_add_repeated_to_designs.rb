class AddRepeatedToDesigns < ActiveRecord::Migration[5.0]
  def change
    add_column :designs, :repeated, :boolean, null: false, default: false
  end
end
