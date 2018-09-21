# frozen_string_literal: true

module Engine
  # Encapsulates a result value for a sobject that identifies the origin of the
  # value, whether the value is a missing code, or simply missing, and other
  # information used by the interpreter.
  class Cell
    attr_accessor :value, :subject_id, :sheet_id, :missing_code

    def initialize(value, subject_id: nil, sheet_id: nil, missing_code: nil)
      @value = value
      @subject_id = subject_id
      @sheet_id = sheet_id
      @missing_code = missing_code
    end

    def missing?
      !!missing_code
    end
  end
end
