class AddMedicationsEnabledToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :medications_enabled, :boolean, null: false, default: false
    add_index :projects, :medications_enabled
  end
end
