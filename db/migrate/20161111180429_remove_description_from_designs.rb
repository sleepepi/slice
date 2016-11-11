class RemoveDescriptionFromDesigns < ActiveRecord::Migration[5.0]
  def change
    remove_column :designs, :description, :text
  end
end
