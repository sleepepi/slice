class CreateAeAdverseEventReviewTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :ae_adverse_event_review_teams do |t|
      t.bigint :ae_adverse_event_id
      t.bigint :ae_review_team_id
      t.timestamps
      t.index [:ae_adverse_event_id, :ae_review_team_id], unique: true, name: "idx_adverse_event_review_team"
    end
  end
end
