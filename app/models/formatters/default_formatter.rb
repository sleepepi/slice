# frozen_string_literal: true

module Formatters
  # Provides default methods for formatting stored database values.
  class DefaultFormatter
    class << self
      def format_array(responses, variable, raw_data)
        new(variable)
        format_array(responses, raw_data)
      end
    end

    def initialize(variable)
      @variable = variable
    end

    def format_array(responses, raw_data)
      @responses = responses
      if raw_data
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
      components(response).compact.join(" ").strip if response.present?
    end

    def components(response)
      [@variable.prepend, raw_response(response), @variable.append]
    end
  end
end
