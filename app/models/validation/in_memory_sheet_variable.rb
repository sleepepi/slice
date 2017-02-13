# frozen_string_literal: true

module Validation
  class InMemorySheetVariable
    attr_accessor :variable, :value, :response_file, :responses

    def initialize(variable, value = nil, response_file = nil, responses = [])
      @variable = variable
      @value = value
      @response_file = response_file
      @responses = responses.collect { |r| Validation::InMemoryResponse.new(r.value) }
    end

    def get_raw_response
      case @variable.variable_type
      when 'checkbox'
        @responses.collect(&:value)
      else
        @value if @value.present?
      end
    end
  end
end
