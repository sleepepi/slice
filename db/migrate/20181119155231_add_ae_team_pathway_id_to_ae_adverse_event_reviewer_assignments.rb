# class AddAeTeamPathwayIdToAeAdverseEventReviewerAssignments < ActiveRecord::Migration[5.2]
#   def change
#     add_column :ae_adverse_event_reviewer_assignments, :ae_team_pathway_id, :bigint
#     add_index :ae_adverse_event_reviewer_assignments, :ae_team_pathway_id, name: "idx_assignment_pathway"
#   end
# end


class AddAeTeamPathwayIdToAeAdverseEventReviewerAssignments < ActiveRecord::Migration[5.2]
  def up
    add_column :ae_adverse_event_reviewer_assignments, :ae_team_pathway_id, :bigint
    remove_index :ae_adverse_event_reviewer_assignments, name: "ae_review_assignment_idx"
    add_index :ae_adverse_event_reviewer_assignments, [:ae_adverse_event_id, :ae_review_team_id, :ae_team_pathway_id, :reviewer_id], unique: true, name: "idx_assignment_pathway"
  end

  def down
    remove_index :ae_adverse_event_reviewer_assignments, name: "idx_assignment_pathway"
    add_index :ae_adverse_event_reviewer_assignments, [:ae_adverse_event_id, :ae_review_team_id, :reviewer_id], unique: true, name: "ae_review_assignment_idx"
    remove_column :ae_adverse_event_reviewer_assignments, :ae_team_pathway_id, :bigint
  end
end
