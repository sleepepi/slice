class AddLevelToSections < ActiveRecord::Migration[4.2]
  def change
    add_column :sections, :level, :integer, null: false, default: 0
  end
end
