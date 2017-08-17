# frozen_string_literal: true

module Formatters
  # Formats date responses.
  class DateFormatter < DefaultFormatter
    # def raw_response(response)
    #   response
    # end

    def name_response(response)
      format = case @variable.date_format
               when "dd/mm/yyyy"
                 "%d/%m/%Y"
               when "yyyy-mm-dd"
                 "%Y-%m-%d"
               when "dd-mmm-yyyy"
                 "%d-%^b-%Y"
               else # "mm/dd/yyyy"
                 "%m/%d/%Y"
               end
      Date.parse(response).strftime(format)
    rescue
      response
    end
  end
end
