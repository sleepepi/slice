# frozen_string_literal: true

# Creates a set of designs required and conditionally required on an event.
# Tracks overall percent completion of the event.
class EventDesign < ApplicationRecord
  # Constants
  REQUIREMENTS = [
    ['Always Required', 'always'],
    ['Conditionally Required', 'conditional']
  ]
  OPERATORS = %w(= < <= > >=)

  # Validation
  validates :position, uniqueness: { scope: [:event_id, :design_id] }

  # Relationships
  belongs_to :event
  belongs_to :design

  # Methods
  def always_required?
    requirement == 'always'
  end

  def conditionally_required?
    requirement == 'conditional'
  end

  def requirement_name
    REQUIREMENTS.find { |_name, value| value == requirement }.first
  end
end
