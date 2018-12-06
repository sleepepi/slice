class AddAeTeamPathwayIdToAeAdverseEventReviewerAssignments < ActiveRecord::Migration[5.2]
  def up
    add_column :ae_adverse_event_reviewer_assignments, :ae_team_pathway_id, :bigint
    add_index :ae_adverse_event_reviewer_assignments, [:ae_adverse_event_id, :ae_review_team_id, :ae_team_pathway_id, :reviewer_id], unique: true, name: "idx_assignment_pathway"
  end

  def down
    remove_index :ae_adverse_event_reviewer_assignments, name: "idx_assignment_pathway"
    remove_column :ae_adverse_event_reviewer_assignments, :ae_team_pathway_id, :bigint
  end
end
