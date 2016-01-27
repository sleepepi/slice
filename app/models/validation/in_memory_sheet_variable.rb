# frozen_string_literal: true

module Validation
  class InMemorySheetVariable
    attr_accessor :variable, :response, :response_file, :responses

    def initialize(variable, response = nil, response_file = nil, responses = [])
      @variable = variable
      @response = response
      @response_file = response_file
      @responses = responses.collect{|r| Validation::InMemoryResponse.new(r.value)}
    end

    def get_raw_response
      case @variable.variable_type when 'checkbox'
        @responses.collect(&:value)
      else
        @response
      end
    end
  end
end
