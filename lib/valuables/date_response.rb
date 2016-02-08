# frozen_string_literal: true

require 'valuables/default'

module Valuables
  class DateResponse < Default
    def name
      format = case @object.variable.format
               when '%d/%m/%Y'
                 '%d/%m/%Y'
               when '%Y-%m-%d'
                 '%Y-%m-%d'
               when 'dd-mmm-yyyy'
                 '%d-%^b-%Y'
               else
                 '%m/%d/%Y'
               end

      Date.parse(@object.response).strftime(format)
    rescue
      @object.response
    end
  end
end
