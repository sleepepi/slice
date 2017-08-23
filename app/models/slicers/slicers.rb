# frozen_string_literal: true

# Checks and Save values to the database.
module Slicers
  DEFAULT_CLASS = Slicers::DefaultSlicer
  SLICER_CLASSES = {
    "calculated" => CalculatedSlicer,
    "checkbox" => CheckboxSlicer,
    "date" => DateSlicer,
    "dropdown" => DropdownSlicer,
    # file
    # grid
    "imperial_height" => ImperialHeightSlicer,
    "imperial_weight" => ImperialWeightSlicer,
    "integer" => IntegerSlicer,
    "numeric" => NumericSlicer,
    "radio" => RadioSlicer,
    "string" => StringSlicer,
    "text" => TextSlicer,
    "time_of_day" => TimeOfDaySlicer,
    "time_duration" => TimeDurationSlicer
    # signature
  }

  def self.for(variable)
    (SLICER_CLASSES[variable.variable_type] || DEFAULT_CLASS).new(variable)
  end
end
