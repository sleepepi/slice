# frozen_string_literal: true

# Represents a sheet associated to an adverse event.
class AeSheet < ApplicationRecord
  # Constants
  ROLES = [
    ["Reporter", "reporter"],
    ["Admin", "admin"],
    ["Principal reviewer", "principal_reviewer"],
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
  belongs_to :ae_adverse_event_reviewer_assignment, optional: true

  # Methods
  def sheet_saved!(current_user, update_type)
    entry_type = if update_type.in?(%w(sheet_create public_sheet_create api_sheet_create))
                   "ae_sheet_created"
                 else
                   "ae_sheet_updated"
                 end
    ae_adverse_event.ae_adverse_event_log_entries.create(
      project: project, user: current_user, entry_type: entry_type, sheets: [sheet]
    )
  end
end
