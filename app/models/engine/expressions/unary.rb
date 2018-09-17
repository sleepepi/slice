# frozen_string_literal: true

module Engine
  module Expressions
    class Unary < Expression
      attr_accessor :operator, :right

      def initialize(operator, right)
        @operator = operator
        @right = right
      end
    end
  end
end
