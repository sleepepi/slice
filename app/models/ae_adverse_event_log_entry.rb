class AeAdverseEventLogEntry < ApplicationRecord
  # Constants
  ENTRY_TYPES = [
    ["Opened.", "ae_opened"],
    ["Sheet created.", "ae_sheet_created"],
    ["Sheet updated.", "ae_sheet_updated"],
    ["Sent for review.", "ae_sent_for_review"],
    ["Info request created.", "ae_info_request_created"],
    ["Info request resolved.", "ae_info_request_resolved"],
    ["Document uploaded.", "ae_document_uploaded"],
    ["Document removed.", "ae_document_removed"],
    ["Team assigned.", "ae_team_assigned"],
    ["Reviewers assigned.", "ae_reviewers_assigned"],
    ["Reviewers unassigned.", "ae_reviewers_unassigned"],
    ["Review completed.", "ae_review_completed"],
    ["Final review completed.", "ae_final_review_completed"],
    ["Team review completed.", "ae_team_review_completed"],
    ["Team review uncompleted.", "ae_team_review_uncompleted"],
    ["Closed.", "ae_closed"],
    ["Reopened.", "ae_reopened"],
  ]

  # Validations
  validates :entry_type, inclusion: { in: ENTRY_TYPES.collect(&:second) }

  # Relationships
  belongs_to :project
  belongs_to :ae_adverse_event
  belongs_to :user
  belongs_to :ae_team, optional: true

  has_many :ae_log_entry_attachments
  has_many :sheets, through: :ae_log_entry_attachments, source: :attachment, source_type: "Sheet"
  has_many :info_requests, through: :ae_log_entry_attachments, source: :attachment, source_type: "AeInfoRequest"
  has_many :assignments, -> { order(:id) }, through: :ae_log_entry_attachments, source: :attachment, source_type: "AeAssignment"
  has_many :documents, through: :ae_log_entry_attachments, source: :attachment, source_type: "AeDocument"

  # Methods
  def entry_type_text
    ENTRY_TYPES.find { |_name, value| value == entry_type }&.first
  end
end
