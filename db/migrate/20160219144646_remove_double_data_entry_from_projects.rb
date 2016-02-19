class RemoveDoubleDataEntryFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :double_data_entry, :boolean, null: false, default: false
  end
end
