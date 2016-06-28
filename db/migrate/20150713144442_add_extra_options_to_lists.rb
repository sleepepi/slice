class AddExtraOptionsToLists < ActiveRecord::Migration[4.2]
  def change
    add_column :lists, :extra_options, :text
  end
end
