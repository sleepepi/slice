# frozen_string_literal: true

module Formatters
  # Used to help format arrays of database responses for integer variables
  class IntegerFormatter < NumericFormatter
    def raw_response(response)
      Integer(format('%d', response))
    rescue
      response
    end
  end
end
