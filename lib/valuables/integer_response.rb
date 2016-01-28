# frozen_string_literal: true

require 'valuables/numeric_response'

module Valuables
  class IntegerResponse < NumericResponse
    def raw
      Integer(format('%.0f', @object.response))
    rescue
      @object.response
    end
  end
end
