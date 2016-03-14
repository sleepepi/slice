# frozen_string_literal: true

class EventDesign < ApplicationRecord
  # Model Validation
  validates :position, uniqueness: { scope: [:event_id, :design_id] }

  # Model Relationships
  belongs_to :event
  belongs_to :design

  # Model Methods
end
