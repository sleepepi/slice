# frozen_string_literal: true

module Validation
  class InMemoryGrid
    attr_accessor :variable, :parent_variable, :position, :response, :response_file, :responses

    def initialize(parent_variable, position, variable, response = nil, response_file = nil, responses = [])
      @parent_variable = parent_variable
      @position = position
      @variable = variable
      @response = response
      @response_file = response_file
      @responses = responses.collect { |r| Validation::InMemoryResponse.new(r.value) }
    end

    def get_raw_response
      case @variable.variable_type
      when 'checkbox'
        @responses.collect(&:value)
      else
        if @response.blank?
          nil
        else
          @response
        end
      end
    end
  end
end
