# frozen_string_literal: true

module Formatters
  # Formats times based on 24 or 12 hour clock.
  class TimeFormatter < DefaultFormatter
    include DateAndTimeParser

    def name_response(response)
      hash = parse_time_of_day(response)
      minutes = format('%02d', hash[:minutes])
      seconds = format('%02d', hash[:seconds])
      if @variable.twelve_hour_clock?
        if @variable.show_seconds?
          "#{hash[:hours]}:#{minutes}:#{seconds} #{hash[:period]}"
        else
          "#{hash[:hours]}:#{minutes} #{hash[:period]}"
        end
      else
        if @variable.show_seconds?
          "#{format('%02d', hash[:hours_24])}:#{minutes}:#{seconds}"
        else
          "#{format('%02d', hash[:hours_24])}:#{minutes}"
        end
      end
    rescue
      response
    end
  end
end
