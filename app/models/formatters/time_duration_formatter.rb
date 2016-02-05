# frozen_string_literal: true

module Formatters
  # Formats time durations
  class TimeDurationFormatter < DefaultFormatter
    include DateAndTimeParser
    # def raw_response(response)
    #   response
    # end

    def name_response(response)
      hash = parse_time_duration(response)
      if @variable.show_seconds?
        "#{hash[:hours]}h #{hash[:minutes]}' #{hash[:seconds]}\""
      else
        "#{hash[:hours]}h #{hash[:minutes]}'"
      end
    rescue
      response
    end
  end
end
