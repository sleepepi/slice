# frozen_string_literal: true

module Engine
  module Expressions
    class Binary < Expression
      attr_accessor :left, :operator, :right

      def initialize(left, operator, right)
        @left = left
        @operator = operator
        @right = right
      end
    end
  end
end
