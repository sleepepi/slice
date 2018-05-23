# frozen_string_literal: true

module Formatters
  # Used to help format arrays of database responses for calculated variables.
  class CalculatedFormatter < NumericFormatter
    def formatted(response)
      return raw_response(response) if @variable.calculated_format.blank?
      format(@variable.calculated_format, raw_response(response))
    rescue
      raw_response(response)
    end
  end
end
