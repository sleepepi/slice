# frozen_string_literal: true

# Represents a supporting document on an adverse event.
class AeDocument < ApplicationRecord
  # Uploaders
  mount_uploader :file, GenericUploader

  # Constants
  ORDERS = {
    "size" => "ae_documents.byte_size",
    "size desc" => "ae_documents.byte_size desc",
    "oldest" => "ae_documents.created_at",
    "latest" => "ae_documents.created_at desc",
    "name" => "LOWER(ae_documents.filename)",
    "name desc" => "LOWER(ae_documents.filename) desc"
  }
  DEFAULT_ORDER = "LOWER(ae_documents.filename)"

  # Concerns
  include Searchable

  # Scopes
  scope :pdfs, -> { where(content_type: "application/pdf") }

  # Validations
  validates :filename, presence: true,
                       uniqueness: { case_sensitive: false, scope: [:ae_adverse_event_id] }

  # Relationships
  belongs_to :project
  belongs_to :ae_adverse_event
  belongs_to :user

  # Methods
  def self.content_type(filename)
    MIME::Types.type_for(filename).first.content_type
  end

  def pdf?
    content_type == "application/pdf"
  end

  def image?
    content_type.in?(["image/gif", "image/jpeg", "image/png"])
  end

  def uploaded!(current_user)
    ae_adverse_event.ae_log_entries.create(
      project: project,
      user: current_user,
      entry_type: "ae_document_uploaded",
      documents: [self]
    )
  end

  def removed!(current_user)
    ae_adverse_event.ae_log_entries.create(
      project: project,
      user: current_user,
      entry_type: "ae_document_removed"
    )
  end
end
