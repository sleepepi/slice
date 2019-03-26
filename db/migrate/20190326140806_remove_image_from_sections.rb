class RemoveImageFromSections < ActiveRecord::Migration[6.0]
  def change
    remove_column :sections, :image, :string
  end
end
