# frozen_string_literal: true

module Formatters
  # Formats imperial weight.
  class ImperialWeightFormatter < DefaultFormatter
    include DateAndTimeParser
    # def raw_response(response)
    #   response
    # end

    def name_response(response)
      hash = parse_imperial_weight(response)
      p = (hash[:pounds] == 1 ? 'pound' : 'pounds')
      o = (hash[:ounces] == 1 ? 'ounce' : 'ounces')
      "#{hash[:pounds]} #{p} #{hash[:ounces]} #{o}"
    rescue
      response
    end
  end
end
