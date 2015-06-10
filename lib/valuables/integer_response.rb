require 'valuables/numeric_response'

module Valuables

  class IntegerResponse < NumericResponse

    def raw
      begin Integer("%g" % @object.response) end rescue @object.response
    end

  end

end
