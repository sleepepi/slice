class CreateAeReviewGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_review_groups do |t|
      t.bigint :project_id
      t.bigint :ae_adverse_event_id
      t.bigint :ae_review_team_id
      t.bigint :ae_team_pathway_id
      t.datetime :final_review_completed_at
      t.bigint :final_reviewer_id
      t.timestamps

      t.index :project_id
      t.index [:ae_adverse_event_id, :ae_review_team_id, :ae_team_pathway_id], unique: true, name: "idx_review_group_pathway"
      t.index :final_reviewer_id
    end

    add_column :ae_adverse_event_reviewer_assignments, :ae_review_group_id, :bigint
    add_index :ae_adverse_event_reviewer_assignments, :ae_review_group_id, name: "idx_review_group_assignment"
  end
end
