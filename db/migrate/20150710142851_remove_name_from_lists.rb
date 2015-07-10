class RemoveNameFromLists < ActiveRecord::Migration
  def change
    remove_column :lists, :name, :string
  end
end
