class RemoveSubSectionFromSections < ActiveRecord::Migration[4.2]
  def change
    remove_column :sections, :sub_section, :boolean, null: false, default: false
  end
end
