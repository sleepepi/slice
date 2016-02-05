# frozen_string_literal: true

require 'valuables/default'

module Valuables
  class TimeResponse < Default
    def name
      if @object.variable.format == '12hour'
        if @object.variable.show_seconds?
          Time.strptime(@object.response, '%H:%M:%S').strftime('%-l:%M:%S %P')
        else
          Time.strptime(@object.response, '%H:%M:%S').strftime('%-l:%M %P')
        end
      else
        if @object.variable.show_seconds?
          @object.response
        else
          Time.strptime(@object.response, '%H:%M:%S').strftime('%H:%M')
        end
      end
    rescue
      @object.response
    end
  end
end
