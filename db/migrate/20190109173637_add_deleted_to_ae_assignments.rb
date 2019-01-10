class AddDeletedToAeAssignments < ActiveRecord::Migration[5.2]
  def change
    add_column :ae_assignments, :deleted, :boolean, null: false, default: false
    add_index :ae_assignments, :deleted
  end
end
