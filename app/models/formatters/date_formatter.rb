module Formatters
  class DateFormatter < DefaultFormatter
    # def raw_response(response)
    #   response
    # end

    def name_response(response)
      format = (@variable.format.blank? ? '%m/%d/%Y' : @variable.format)
      Date.parse(response).strftime(format)
    rescue
      response
    end
  end
end
