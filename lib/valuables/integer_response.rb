require 'valuables/numeric_response'

module Valuables

  class IntegerResponse < NumericResponse

    def raw
      begin Integer(@object.response) end rescue @object.response
    end

  end

end
