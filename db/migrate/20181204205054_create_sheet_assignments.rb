class CreateSheetAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :sheet_assignments do |t|
      t.bigint :project_id
      t.bigint :sheet_id
      t.bigint :ae_adverse_event_id
      t.bigint :ae_review_team_id
      t.bigint :ae_team_pathway_id
      t.bigint :ae_adverse_event_reviewer_assignment_id
      t.timestamps

      t.index :project_id
      t.index :sheet_id
      t.index :ae_adverse_event_id
      t.index :ae_review_team_id
      t.index :ae_team_pathway_id
      t.index :ae_adverse_event_reviewer_assignment_id, name: "idx_sheet_reviewer_assignment"
    end
  end
end
