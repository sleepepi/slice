# frozen_string_literal: true

# Efficiently format arrays of responses for a variable
module Formatters
  DEFAULT_CLASS = Formatters::DefaultFormatter
  FORMATTER_CLASSES = {
    'date' => Formatters::DateFormatter,
    'checkbox' => Formatters::DomainFormatter,
    'dropdown' => Formatters::DomainFormatter,
    'radio' => Formatters::DomainFormatter,
    'integer' => Formatters::IntegerFormatter,
    'calculated' => Formatters::NumericFormatter,
    'numeric' => Formatters::NumericFormatter,
    'time_duration' => Formatters::TimeDurationFormatter,
    'time' => Formatters::TimeFormatter
  }

  def self.for(variable)
    (FORMATTER_CLASSES[variable.variable_type] || DEFAULT_CLASS).new(variable)
  end
end
