# frozen_string_literal: true

module Formatters
  # Formats time of day based on 24 or 12 hour clock.
  class TimeOfDayFormatter < DefaultFormatter
    include DateAndTimeParser

    def name_response(response)
      hash = parse_time_of_day(response)
      minutes = format(":%02d", hash[:minutes])
      seconds = @variable.show_seconds? ? format(":%02d", hash[:seconds]) : ""
      if @variable.twelve_hour_clock?
        "#{hash[:hours]}#{minutes}#{seconds} #{hash[:period]}"
      else
        "#{format('%02d', hash[:hours_24])}#{minutes}#{seconds}"
      end
    rescue
      response
    end
  end
end
