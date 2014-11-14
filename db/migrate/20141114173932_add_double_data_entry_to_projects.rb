class AddDoubleDataEntryToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :double_data_entry, :boolean, null: false, default: false
  end
end
