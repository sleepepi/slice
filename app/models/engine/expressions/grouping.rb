# frozen_string_literal: true

module Engine
  module Expressions
    class Grouping < Expression
      attr_accessor :expression

      def initialize(expression)
        @expression = expression
      end
    end
  end
end
