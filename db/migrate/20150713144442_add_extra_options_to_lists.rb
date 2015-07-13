class AddExtraOptionsToLists < ActiveRecord::Migration
  def change
    add_column :lists, :extra_options, :text
  end
end
