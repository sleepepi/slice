class AddDoubleDataEntryToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :double_data_entry, :boolean, null: false, default: false
  end
end
