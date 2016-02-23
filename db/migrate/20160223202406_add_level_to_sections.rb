class AddLevelToSections < ActiveRecord::Migration
  def change
    add_column :sections, :level, :integer, null: false, default: 0
  end
end
