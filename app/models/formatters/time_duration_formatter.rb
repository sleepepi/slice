# frozen_string_literal: true

module Formatters
  # Formats time durations.
  class TimeDurationFormatter < DefaultFormatter
    include DateAndTimeParser

    def name_response(response)
      hash = parse_time_duration(response)
      h = (hash[:hours] == 1 ? 'hour' : 'hours')
      m = (hash[:minutes] == 1 ? 'minute' : 'minutes')
      s = (hash[:seconds] == 1 ? 'second' : 'seconds')
      case @variable.time_duration_format
      when 'mm:ss'
        "#{hash[:minutes]} #{m} #{hash[:seconds]} #{s}"
      when 'hh:mm'
        "#{hash[:hours]} #{h} #{hash[:minutes]} #{m}"
      else
        "#{hash[:hours]} #{h} #{hash[:minutes]} #{m} #{hash[:seconds]} #{s}"
      end
    rescue
      response
    end
  end
end
