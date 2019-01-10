class AddTeamReviewCompletedAtToAeAdverseEventReviewTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :ae_adverse_event_review_teams, :team_review_completed_at, :datetime
    add_index :ae_adverse_event_review_teams, :team_review_completed_at
  end
end
