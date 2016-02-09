# frozen_string_literal: true

require 'valuables/default'

module Valuables
  class TimeDurationResponse < Default
    include DateAndTimeParser

    def name
      hash = parse_time_duration(@object.response)
      case @object.variable.time_duration_format
      when 'mm:ss'
        "#{hash[:minutes]}m #{hash[:seconds]}s"
      when 'hh:mm'
        "#{hash[:hours]}h #{hash[:minutes]}m"
      else # 'hh:mm:ss'
        "#{hash[:hours]}h #{hash[:minutes]}m #{hash[:seconds]}s"
      end
    rescue
      @object.response
    end
  end
end
