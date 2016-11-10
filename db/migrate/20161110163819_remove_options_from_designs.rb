class RemoveOptionsFromDesigns < ActiveRecord::Migration[5.0]
  def change
    remove_column :designs, :options, :text
  end
end
