# frozen_string_literal: true

# Tracks if a user has seen changes to adverse events, new sheet comments, and
# completed tablet handoffs
class Notification < ActiveRecord::Base
  # Model Validation
  validates :user_id, :project_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :adverse_event
  belongs_to :comment
  belongs_to :handoff
end
