class AddPrincipalToAeAssignments < ActiveRecord::Migration[5.2]
  def change
    add_column :ae_adverse_event_reviewer_assignments, :principal, :boolean, null: false, default: false
    add_index :ae_adverse_event_reviewer_assignments, :principal
  end
end
