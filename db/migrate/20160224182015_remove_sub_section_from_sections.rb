class RemoveSubSectionFromSections < ActiveRecord::Migration
  def change
    remove_column :sections, :sub_section, :boolean, null: false, default: false
  end
end
