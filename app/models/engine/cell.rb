# frozen_string_literal: true

module Engine
  # Encapsulates a result value for a sobject that identifies the origin of the
  # value, whether the value is a missing code, or simply missing, and other
  # information used by the interpreter.
  class Cell
    attr_accessor :value, :subject_id, :missing_code, :coverage, :seds

    def initialize(value, subject_id: nil, missing_code: nil, coverage: nil, seds: [])
      @value = value
      @subject_id = subject_id
      @missing_code = missing_code
      @coverage = coverage
      @seds = seds
    end

    def missing?
      !!missing_code
    end

    def add_sed(sheet_id: nil, event_id: nil, design_id: nil)
      @seds << ::Engine::Sed.new(sheet_id: sheet_id, event_id: event_id, design_id: design_id)
    end
  end
end
