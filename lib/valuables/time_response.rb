# frozen_string_literal: true

require 'valuables/default'

module Valuables
  class TimeResponse < Default
    def name
      if @object.variable.format == '12hour'
        Time.strptime(@object.response, '%H:%M:%S').strftime('%-l:%M:%S %P')
      else
        @object.response
      end
    rescue
      @object.response
    end
  end
end
