# frozen_string_literal: true

class AdverseEventReview < ActiveRecord::Base
  # Model Validation
  validates :adverse_event_id, :name, :comment, presence: true

  # Model Relationships
  belongs_to :adverse_event
end
