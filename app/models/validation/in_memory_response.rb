# frozen_string_literal: true

module Validation
  class InMemoryResponse
    attr_accessor :value

    def initialize(value)
      @value = value
    end
  end
end
