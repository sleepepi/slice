# frozen_string_literal: true

# Represents a sheet associated to an adverse event.
class AeSheet < ApplicationRecord
  # Constants
  ROLES = [
    ["Reporter", "reporter"],
    ["Admin", "admin"],
    ["Manager", "manager"],
    ["Reviewer", "reviewer"]
  ]

  # Validations
  validates :sheet_id, uniqueness: { scope: :ae_adverse_event_id }
  validates :role, inclusion: { in: ROLES.collect(&:second) }

  # Relationships
  belongs_to :project
  belongs_to :ae_adverse_event
  belongs_to :sheet
  belongs_to :ae_review_team, optional: true
  belongs_to :ae_review_group, optional: true
  belongs_to :ae_adverse_event_reviewer_assignment, optional: true
end
