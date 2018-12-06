# frozen_string_literal: true

# Represents the selection of a pathway and reviewer assignments by a team
# manager, along with the final review of the AE for that pathway.
class AeReviewGroup < ApplicationRecord
  # Validations
  validates :ae_team_pathway_id, uniqueness: { scope: :ae_review_team_id }

  # Relationships
  belongs_to :project
  belongs_to :ae_adverse_event
  belongs_to :ae_review_team
  belongs_to :ae_team_pathway
  belongs_to :final_reviewer, class_name: "User", foreign_key: "final_reviewer_id", optional: true
  has_many :ae_adverse_event_reviewer_assignments
  has_many :ae_review_group_sheets
  has_many :sheets, through: :ae_review_group_sheets

  # Methods
  delegate :first_design, to: :ae_team_pathway
  delegate :next_design, to: :ae_team_pathway

  def completed?
    !final_review_completed_at.nil?
  end

  def complete!(current_user)
    return if completed?
    update(final_review_completed_at: Time.zone.now, final_reviewer: current_user)
    # TODO correct final log entry
    log_entry = ae_adverse_event.ae_adverse_event_log_entries.create(project: project, user: current_user, entry_type: "ae_final_review_completed", ae_review_team: ae_review_team) # TODO: Add review group? review_groups: [self]
    # TODO: Generate in app notifications, email, and LOG notifications to AENotificationsLog (for team manager)
    # TODO: Check if all assignments are completed...if so, a "FINAL" adjudicated review is required by the manager (team).
  end

end
