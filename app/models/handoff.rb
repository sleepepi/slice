# frozen_string_literal: true

# Handles authentication for filling out a series of designs on an event
class Handoff < ApplicationRecord
  # Callbacks
  after_create_commit :set_token

  # Validations
  validates :user_id, :project_id, :subject_event_id, presence: true
  validates :token, uniqueness: { scope: :project_id }, allow_nil: true
  validates :subject_event_id, uniqueness: { scope: :project_id }

  # Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :subject_event

  # Methods

  def to_param
    "#{id}-#{token}"
  end

  def self.find_by_param(input)
    clean_input = input.to_param.to_s
    handoff_id = clean_input.split("-").first
    handoff_token = clean_input.gsub(/^#{handoff_id}-/, "")
    handoff = Handoff.find_by(id: handoff_id)
    # Use Devise.secure_compare to mitigate timing attacks
    handoff if handoff && Devise.secure_compare(handoff.token, handoff_token)
  end

  def handoff_enabled_event_designs
    subject_event.event.event_designs.where(handoff_enabled: true)
  end

  def first_design
    event_design = handoff_enabled_event_designs.first
    event_design.design if event_design
  end

  def next_design(design)
    number = handoff_enabled_event_designs.pluck(:design_id).index(design.id)
    event_design = handoff_enabled_event_designs[number + 1] if number
    event_design.design if event_design
  end

  def resume_design
    event_design = handoff_enabled_event_designs.where.not(design_id: select_design_ids).first
    event_design.design if event_design
  end

  def select_design_ids
    subject_event.sheets.select(:design_id)
  end

  def set_token
    return true if token.present?
    update token: SecureRandom.hex(8)
    true
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    retry
  end

  def completed!
    update token: nil
    create_notification
  end

  def create_notification
    notification = user.notifications.where(project_id: project_id, handoff_id: id).first_or_create
    notification.mark_as_unread!
  end
end
