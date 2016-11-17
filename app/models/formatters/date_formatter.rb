# frozen_string_literal: true

module Formatters
  # Formats date responses.
  class DateFormatter < DefaultFormatter
    # def raw_response(response)
    #   response
    # end

    def name_response(response)
      format = case @variable.format
               when '%d/%m/%Y'
                 '%d/%m/%Y'
               when '%Y-%m-%d'
                 '%Y-%m-%d'
               when 'dd-mmm-yyyy'
                 '%d-%^b-%Y'
               else
                 '%m/%d/%Y'
               end
      Date.parse(response).strftime(format)
    rescue
      response
    end
  end
end
