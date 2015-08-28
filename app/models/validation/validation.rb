module Validation

  DEFAULT_CLASS = Validation::Validators::Default
  VALIDATOR_CLASSES = {
    'calculated' => Validation::Validators::Numeric,
    'checkbox' => Validation::Validators::MultipleChoice,
    'date' => Validation::Validators::Date,
    'dropdown' => Validation::Validators::SingleChoice,
    # 'file' => Validation::Validators::File,
    # 'grid' => Validation::Validators::Grid,
    'integer' => Validation::Validators::Integer,
    'numeric' => Validation::Validators::Numeric,
    'radio' => Validation::Validators::SingleChoice,
    'signature' => Validation::Validators::Signature
    # 'string' => Validation::Validators::String,
    # 'text' => Validation::Validators::Text,
    # 'time' => Validation::Validators::TimeOfDay,
    # 'time_duration' => Validation::Validators::TimeDuration
  }

  def self.for(object)
    (VALIDATOR_CLASSES[object.variable_type] || DEFAULT_CLASS).new(object)
  end

end
