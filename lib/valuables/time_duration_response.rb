# frozen_string_literal: true

require 'valuables/default'

module Valuables
  class TimeDurationResponse < Default
    include DateAndTimeParser

    def name
      hash = parse_time_duration(@object.response)
      h = (hash[:hours] == 1 ? 'hour' : 'hours')
      m = (hash[:minutes] == 1 ? 'minute' : 'minutes')
      s = (hash[:seconds] == 1 ? 'second' : 'seconds')
      case @object.variable.time_duration_format
      when 'mm:ss'
        "#{hash[:minutes]} #{m} #{hash[:seconds]} #{s}"
      when 'hh:mm'
        "#{hash[:hours]} #{h} #{hash[:minutes]} #{m}"
      else
        "#{hash[:hours]} #{h} #{hash[:minutes]} #{m} #{hash[:seconds]} #{s}"
      end
    rescue
      @object.response
    end
  end
end
