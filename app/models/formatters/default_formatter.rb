# frozen_string_literal: true

module Formatters
  # Provides default methods for returning and formatting stored database values
  class DefaultFormatter
    class << self
      def format_array(responses, variable, raw_data)
        new(responses, variable, raw_data).format_array
      end
    end

    def initialize(responses, variable, raw_data)
      @responses = responses
      @variable = variable
      @raw_data = raw_data
    end

    def format_array
      if @raw_data
        raw_responses
      else
        name_responses
      end
    end

    def raw_responses
      @responses.collect { |r| raw_response(r) }
    end

    def name_responses
      @responses.collect { |r| name_response(r) }
    end

    def raw_response(response)
      response
    end

    def name_response(response)
      components(response).compact.join(' ').squish if response.present?
    end

    def components(response)
      [@variable.prepend, raw_response(response), @variable.append]
    end
  end
end
