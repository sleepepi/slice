# frozen_string_literal: true

# AeAdverseEvent
# `- AeReviewTeam
#    `- AeTeamPathway
#       `- AeReviewGroup
#          `- AeAdverseEventReviewerAssignment   <=>  AeSheet  <=>  Sheet
class AeAdverseEventReviewerAssignment < ApplicationRecord
  # Validations

  validates :reviewer_id, uniqueness: { scope: [:ae_adverse_event_id, :ae_review_team_id, :ae_team_pathway_id] }

  # Relationships
  belongs_to :project
  belongs_to :ae_adverse_event
  belongs_to :ae_review_team
  belongs_to :ae_team_pathway
  belongs_to :ae_review_group
  belongs_to :manager, class_name: "User", foreign_key: "manager_id"
  belongs_to :reviewer, class_name: "User", foreign_key: "reviewer_id"
  has_many :ae_sheets
  has_many :sheets, through: :ae_sheets

  # Methods
  delegate :first_design, to: :ae_team_pathway
  delegate :next_design, to: :ae_team_pathway

  def overdue?
    !completed? && created_at < Time.zone.now - 2.weeks
  end

  def completed?
    !review_completed_at.nil?
  end

  # TODO: Currently not possible for someone else to complete a assignment for the initial reviewer.
  def complete!
    return if completed?
    update(review_completed_at: Time.zone.now)
    log_entry = ae_adverse_event.ae_adverse_event_log_entries.create(project: project, user: reviewer, entry_type: "ae_review_completed", ae_review_team: ae_review_team, reviewer_assignments: [self])
    # TODO: Generate in app notifications, email, and LOG notifications to AENotificationsLog (for team manager)
    # TODO: Check if all assignments are completed...if so, a "FINAL" adjudicated review is required by the manager (team).
  end
end
