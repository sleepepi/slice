class ChangeCategoryIdToBigint < ActiveRecord::Migration[5.2]
  def up
    change_column :categories, :id, :bigint
    change_column :designs, :category_id, :bigint
  end

  def down
    change_column :categories, :id, :integer
    change_column :designs, :category_id, :integer
  end
end
