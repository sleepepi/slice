# frozen_string_literal: true

module Validation
  # Represents an in memory grid that mimics a Grid saved in the database.
  class InMemoryGrid
    attr_accessor :variable, :parent_variable, :position, :value, :response_file, :responses

    def initialize(parent_variable, position, variable, value: nil, response_file: nil, responses: [])
      @parent_variable = parent_variable
      @position = position
      @variable = variable
      @value = value
      @response_file = response_file
      @responses = responses.collect { |r| Validation::InMemoryResponse.new(r.value) }
    end

    def raw_response
      case @variable.variable_type
      when 'checkbox'
        @responses.collect(&:value)
      else
        @value if @value.present?
      end
    end
  end
end
