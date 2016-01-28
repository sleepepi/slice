# frozen_string_literal: true

require 'valuables/default'

module Valuables
  class DateResponse < Default
    def name
      format = (@object.variable.format.blank? ? '%m/%d/%Y' : @object.variable.format)
      Date.parse(@object.response).strftime(format)
    rescue
      @object.response
    end
  end
end
