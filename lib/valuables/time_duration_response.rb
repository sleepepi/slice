# frozen_string_literal: true

require 'valuables/default'

module Valuables
  class TimeDurationResponse < Default
    include DateAndTimeParser

    def name
      hash = parse_time_duration(@object.response)
      "#{hash[:hours]}h #{hash[:minutes]}' #{hash[:seconds]}\""
    rescue
      @object.response
    end
  end
end
