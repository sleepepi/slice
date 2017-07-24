# frozen_string_literal: true

# Efficiently format arrays of responses for a variable
module Formatters
  DEFAULT_CLASS = Formatters::DefaultFormatter
  FORMATTER_CLASSES = {
    "date" => Formatters::DateFormatter,
    "checkbox" => Formatters::DomainFormatter,
    "dropdown" => Formatters::DomainFormatter,
    "radio" => Formatters::DomainFormatter,
    "file" => Formatters::FileFormatter,
    "integer" => Formatters::IntegerFormatter,
    "calculated" => Formatters::NumericFormatter,
    "numeric" => Formatters::NumericFormatter,
    "imperial_height" => Formatters::ImperialHeightFormatter,
    "imperial_weight" => Formatters::ImperialWeightFormatter,
    "signature" => Formatters::SignatureFormatter,
    "time_duration" => Formatters::TimeDurationFormatter,
    "time_of_day" => Formatters::TimeOfDayFormatter
  }

  def self.for(variable)
    (FORMATTER_CLASSES[variable.variable_type] || DEFAULT_CLASS).new(variable)
  end
end
