# frozen_string_literal: true

module Formatters
  # Formats times based on 24 or 12 hour clock
  class TimeFormatter < DefaultFormatter
    # def raw_response(response)
    #   response
    # end

    def name_response(response)
      format = if @variable.format == '12hour'
                 @variable.show_seconds? ? '%-l:%M:%S %P' : '%-l:%M %P'
               else
                 @variable.show_seconds? ? '%H:%M:%S' : '%H:%M'
               end
      Time.zone.strptime(response, '%H:%M:%S').strftime(format)
    rescue
      response
    end
  end
end
