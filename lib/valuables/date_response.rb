require 'valuables/default'

module Valuables

  class DateResponse < Default

    def name
      Date.parse(@object.response).strftime(@object.variable.format.blank? ? "%Y-%m-%d" : @object.variable.format ) rescue @object.response
    end

  end

end
