# frozen_string_literal: true

module Formatters
  # Formats imperial weight.
  class ImperialWeightFormatter < IntegerFormatter
    include DateAndTimeParser

    def name_response(response, shared_responses = domain_options)
      hash = parse_imperial_weight(response)
      p = (hash[:pounds] == 1 ? "pound" : "pounds")
      o = (hash[:ounces] == 1 ? "ounce" : "ounces")
      "#{hash[:pounds]} #{p} #{hash[:ounces]} #{o}"
    rescue
      response
    end
  end
end
