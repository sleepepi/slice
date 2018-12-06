# frozen_string_literal: true

# Represents the assignment of an adverse event to a review team.
class AeAdverseEventReviewTeam < ApplicationRecord
  # Validations
  validates :ae_adverse_event_id, uniqueness: { scope: :ae_review_team_id }

  # Relationships
  belongs_to :project
  belongs_to :ae_adverse_event
  belongs_to :ae_review_team
end
