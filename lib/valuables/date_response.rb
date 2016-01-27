# frozen_string_literal: true

require 'valuables/default'

module Valuables
  class DateResponse < Default
    def name
      Date.parse(@object.response).strftime(@object.variable.format.blank? ? "%m/%d/%Y" : @object.variable.format ) rescue @object.response
    end
  end
end
