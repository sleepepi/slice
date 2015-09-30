# Files can be uploaded and attached to adverse events
class AdverseEventFile < ActiveRecord::Base
  # Uploaders
  mount_uploader :attachment, GenericUploader

  # Model Validation
  validates :project_id, :user_id, :adverse_event_id, :attachment, presence: true

  # Model Relationships
  belongs_to :project
  belongs_to :adverse_event
  belongs_to :user

  # Model Methods

  def name
    attachment.path.split('/').last
  end

  def pdf?
    name.last(4).to_s.downcase == '.pdf'
  end

  def image?
    %w(.png .jpg .gif).include?(name.last(4).to_s.downcase)
  end
end
