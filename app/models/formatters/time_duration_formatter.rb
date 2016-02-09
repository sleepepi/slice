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
      case @variable.time_duration_format
      when 'mm:ss'
        "#{hash[:minutes]}m #{hash[:seconds]}s"
      when 'hh:mm'
        "#{hash[:hours]}h #{hash[:minutes]}m"
      else # 'hh:mm:ss'
        "#{hash[:hours]}h #{hash[:minutes]}m #{hash[:seconds]}s"
      end
    rescue
      response
    end
  end
end
