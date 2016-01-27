# frozen_string_literal: true

require 'valuables/numeric_response'

module Valuables
  class IntegerResponse < NumericResponse
    def raw
      begin Integer('%.0f' % @object.response) end rescue @object.response
    end
  end
end
