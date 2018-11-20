# frozen_string_literal: true

# Represents the assignment of an adverse event to a review team.
class AeAdverseEventReviewTeam < ApplicationRecord
  # Validations
  validates :ae_adverse_event_id, uniqueness: { scope: :ae_review_team_id }

  # Relationships
  belongs_to :project
  belongs_to :ae_adverse_event
  belongs_to :ae_review_team

  # Methods

  def assign_pathway!(current_user, pathway)
    reviewers = random_reviewers(pathway)

    assignments = []
    reviewers.each do |reviewer|
      assignments << ae_adverse_event.ae_adverse_event_reviewer_assignments.create(
        project: project,
        ae_review_team: ae_review_team,
        manager: current_user,
        reviewer: reviewer,
        ae_team_pathway: pathway
      )
      # TODO: Generate in app notifications, email, and LOG notificiations to AENotificationsLog for Info Request (to "reviewer")
    end
    ae_adverse_event.ae_adverse_event_log_entries.create(
      project: project,
      user: current_user,
      entry_type: "ae_reviewers_assigned",
      ae_review_team: ae_review_team,
      reviewer_assignments: assignments
    )
  end

  private

  def random_reviewers(pathway)
    if pathway.number_of_reviewers.zero?
      ae_review_team.reviewers
    else
      ae_review_team.reviewers.sample(pathway.number_of_reviewers)
    end
  end
end
