class AddPrincipalToAeAssignments < ActiveRecord::Migration[5.2]
  def change
    add_column :ae_assignments, :principal, :boolean, null: false, default: false
    add_index :ae_assignments, :principal
  end
end
