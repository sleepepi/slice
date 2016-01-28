module Formatters
  # Used to help format arrays of database responses for integer variables
  class NumericFormatter < DomainFormatter
    def raw_response(response)
      Float(response)
    rescue
      response
    end
  end
end
