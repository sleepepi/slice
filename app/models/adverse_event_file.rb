# frozen_string_literal: true

# Files can be uploaded and attached to adverse events.
class AdverseEventFile < ApplicationRecord
  # Uploaders
  mount_uploader :attachment, GenericUploader

  # Validations
  validates :attachment, presence: true

  # Relationships
  belongs_to :project
  belongs_to :adverse_event, touch: true
  belongs_to :user

  # Methods
  def name
    attachment_identifier
  end

  def pdf?
    extension == "pdf"
  end

  def image?
    %w(png jpg jpeg gif).include?(extension)
  end

  def extension
    attachment.file.extension.to_s.downcase
  end
end
