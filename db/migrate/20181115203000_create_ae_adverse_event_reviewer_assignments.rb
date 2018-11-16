class CreateAeAdverseEventReviewerAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_adverse_event_reviewer_assignments do |t|
      t.bigint :project_id
      t.bigint :ae_adverse_event_id
      t.bigint :ae_review_team_id
      t.bigint :manager_id
      t.bigint :reviewer_id
      t.datetime :review_completed_at
      t.datetime :review_unassigned_at
      t.timestamps
      t.index :project_id
      t.index [:ae_adverse_event_id, :ae_review_team_id, :reviewer_id], unique: true, name: "ae_review_assignment_idx"
      t.index :manager_id
      t.index :review_completed_at, name: "ae_review_completed_idx"
      t.index :review_unassigned_at, name: "ae_review_unassigned_idx"
    end
  end
end
