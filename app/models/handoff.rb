# Handles authentication for filling out a series of designs on an event
class Handoff < ActiveRecord::Base
  # Callbacks
  after_create :set_token

  # Model Validation
  validates :user_id, :project_id, :subject_event_id, presence: true
  validates :token, uniqueness: { scope: :project_id }, allow_nil: true
  validates :subject_event_id, uniqueness: { scope: :project_id }

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :subject_event

  # Model Methods

  def next_design(design)
    number = subject_event.event.designs.pluck(:id).index(design.id)
    subject_event.event.designs[number + 1] if number
  end

  def set_token
    return unless token.blank?
    update token: SecureRandom.hex(8)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    retry
  end
end
