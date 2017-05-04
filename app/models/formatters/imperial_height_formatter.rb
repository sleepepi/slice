# frozen_string_literal: true

module Formatters
  # Formats imperial height.
  class ImperialHeightFormatter < IntegerFormatter
    include DateAndTimeParser

    def name_response(response)
      hash = parse_imperial_height(response)
      f = (hash[:feet] == 1 ? 'foot' : 'feet')
      i = (hash[:inches] == 1 ? 'inch' : 'inches')
      "#{hash[:feet]} #{f} #{hash[:inches]} #{i}"
    rescue
      response
    end
  end
end
