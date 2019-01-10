# frozen_string_literal: true

# Represents the assignment of an adverse event to a review team.
class AeAdverseEventTeam < ApplicationRecord
  # Validations
  validates :ae_adverse_event_id, uniqueness: { scope: :ae_team_id }

  # Relationships
  belongs_to :project
  belongs_to :ae_adverse_event
  belongs_to :ae_team

  # Methods
  def team_review_completed?
    !team_review_completed_at.nil?
  end

  def team_review_uncompleted?
    !team_review_completed?
  end
end
