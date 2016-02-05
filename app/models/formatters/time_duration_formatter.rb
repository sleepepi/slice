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
        "#{hash[:hours]}h #{hash[:minutes]}m #{hash[:seconds]}s"
      else
        "#{hash[:hours]}h #{hash[:minutes]}m"
      end
    rescue
      response
    end
  end
end
