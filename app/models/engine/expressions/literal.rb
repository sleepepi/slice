# frozen_string_literal: true

module Engine
  module Expressions
    class Literal < Expression
      attr_accessor :value

      def initialize(value)
        @value = value
      end
    end
  end
end
