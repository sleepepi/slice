class RemoveNameFromLists < ActiveRecord::Migration[4.2]
  def change
    remove_column :lists, :name, :string
  end
end
