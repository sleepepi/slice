# frozen_string_literal: true

# Tracks if a user has seen changes to adverse events, new sheet comments, and
# completed tablet handoffs.
class Notification < ApplicationRecord
  # Validations
  validates :user_id, :project_id, presence: true

  # Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :adverse_event, optional: true
  belongs_to :comment, optional: true
  belongs_to :export, optional: true
  belongs_to :handoff, optional: true
  belongs_to :sheet, optional: true
  belongs_to :sheet_unlock_request, optional: true

  # Methods
  def mark_as_unread!
    update created_at: Time.zone.now, read: false
  end
end
