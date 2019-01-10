class CreateAeAssignments < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_assignments do |t|
      t.bigint :project_id
      t.bigint :ae_adverse_event_id
      t.bigint :ae_team_id
      t.bigint :manager_id
      t.bigint :reviewer_id
      t.datetime :review_completed_at
      t.datetime :review_unassigned_at
      t.timestamps
      t.index :project_id
      t.index :manager_id
      t.index :review_completed_at
      t.index :review_unassigned_at
    end
  end
end
