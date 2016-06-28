class AddCategoryIdToDesigns < ActiveRecord::Migration[4.2]
  def change
    add_column :designs, :category_id, :integer
    add_index :designs, :category_id
  end
end
