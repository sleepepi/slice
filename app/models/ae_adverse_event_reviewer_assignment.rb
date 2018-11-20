# frozen_string_literal: true

class AeAdverseEventReviewerAssignment < ApplicationRecord
  # Validations

  validates :reviewer_id, uniqueness: { scope: [:ae_adverse_event_id, :ae_review_team_id, :ae_team_pathway_id] }

  # Relationships
  belongs_to :project
  belongs_to :ae_adverse_event
  belongs_to :ae_review_team
  belongs_to :ae_team_pathway
  belongs_to :manager, class_name: "User", foreign_key: "manager_id"
  belongs_to :reviewer, class_name: "User", foreign_key: "reviewer_id"

  # Methods

  def completed?
    !review_completed_at.nil?
  end

  # TODO: Currently not possible for someone else to complete a assignment for the initial reviewer.
  def complete!
    update(review_completed_at: Time.zone.now)
    log_entry = ae_adverse_event.ae_adverse_event_log_entries.create(project: project, user: reviewer, entry_type: "ae_review_completed", ae_review_team: ae_review_team, reviewer_assignments: [self])
    # TODO: Generate in app notifications, email, and LOG notifications to AENotificationsLog (for team manager)
    # TODO: Check if all assignments are completed...if so, a "FINAL" adjudicated review is required by the manager (team).
  end
end
