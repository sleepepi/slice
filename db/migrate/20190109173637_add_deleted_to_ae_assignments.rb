class AddDeletedToAeAssignments < ActiveRecord::Migration[5.2]
  def change
    add_column :ae_adverse_event_reviewer_assignments, :deleted, :boolean, null: false, default: false
    add_index :ae_adverse_event_reviewer_assignments, :deleted
  end
end
