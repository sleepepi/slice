class AddAeTeamPathwayIdToAeAssignments < ActiveRecord::Migration[5.2]
  def up
    add_column :ae_assignments, :ae_team_pathway_id, :bigint
    add_index :ae_assignments, [:ae_adverse_event_id, :ae_team_id, :ae_team_pathway_id, :reviewer_id], unique: true, name: "idx_assignment_pathway"
  end

  def down
    remove_index :ae_assignments, name: "idx_assignment_pathway"
    remove_column :ae_assignments, :ae_team_pathway_id, :bigint
  end
end
