# frozen_string_literal: true

module Engine
  module Expressions
    class Between < Expression
      attr_accessor :left, :lower, :higher

      def initialize(left, lower, higher)
        @left = left
        @lower = lower
        @higher = higher
      end
    end
  end
end
