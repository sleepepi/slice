class AeAdverseEventLogEntry < ApplicationRecord
  # Constants
  ENTRY_TYPES = [
    ["Adverse event opened.", "ae_opened"],
    ["Adverse event sheet created.", "ae_sheet_created"],
    ["Adverse event sheet updated.", "ae_sheet_updated"],
    ["Adverse event info request created.", "ae_info_request_created"],
    ["Adverse event info request resolved.", "ae_info_request_resolved"],
    ["Adverse event document uploaded.", "ae_document_uploaded"],
    ["Adverse event team assigned.", "ae_team_assigned"],
    ["Adverse event reviewers assigned.", "ae_reviewers_assigned"],
    ["Adverse event review completed.", "ae_review_completed"],
    ["Adverse event final review completed.", "ae_final_review_completed"],
    ["Adverse event closed.", "ae_closed"]
  ]

  # Validations
  validates :entry_type, inclusion: { in: ENTRY_TYPES.collect(&:second) }

  # Relationships
  belongs_to :project
  belongs_to :ae_adverse_event
  belongs_to :user
  belongs_to :ae_review_team, optional: true

  has_many :ae_log_entry_attachments
  has_many :sheets, through: :ae_log_entry_attachments, source: :attachment, source_type: "Sheet"
  has_many :info_requests, through: :ae_log_entry_attachments, source: :attachment, source_type: "AeAdverseEventInfoRequest"
  has_many :reviewer_assignments, -> { order(:id) }, through: :ae_log_entry_attachments, source: :attachment, source_type: "AeAdverseEventReviewerAssignment"
end
