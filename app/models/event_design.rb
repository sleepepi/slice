# frozen_string_literal: true

# Creates a set of designs required and conditionally required on an event.
# Tracks overall percent completion of the event.
class EventDesign < ApplicationRecord
  # Constants
  REQUIREMENTS = [
    ['Always Required', 'always'],
    ['Conditionally Required', 'conditional']
  ]
  OPERATORS = %w(= < <= > >= !=)

  # Concerns
  include Squishable
  squish :conditional_value

  # Validation
  validates :position, uniqueness: { scope: [:event_id, :design_id] }

  # Relationships
  belongs_to :event
  belongs_to :design
  belongs_to :conditional_event, class_name: 'Event'
  belongs_to :conditional_design, class_name: 'Design'
  belongs_to :conditional_variable, class_name: 'Variable'

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

  def required?(subject)
    return true if always_required?
    subject.evaluate?(
      event: conditional_event,
      design: conditional_design,
      variable: conditional_variable,
      value: conditional_value,
      operator: conditional_operator
    )
  end
end
