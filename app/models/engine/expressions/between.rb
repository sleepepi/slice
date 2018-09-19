# frozen_string_literal: true

module Engine
  module Expressions
    class Between < Expression
      attr_accessor :left, :operator, :lower, :higher

      def initialize(left, operator, lower, higher)
        @left = left
        @operator = operator
        @lower = lower
        @higher = higher
      end
    end
  end
end
