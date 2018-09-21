# frozen_string_literal: true

module Engine
  module Operations
    module Exponent
      def operation_exponent(left, right)
        if left.zero? && right.zero?
          nil
        elsif left.is_a?(Numeric) && right.is_a?(Numeric)
          left.send(:**, right)
        else
          nil
        end
      end

      def operation_exponent_cell(left, right)
        left = left.value if left.is_a?(::Engine::Cell)
        right = right.value if right.is_a?(::Engine::Cell)
        operation_exponent(left, right)
      end
    end
  end
end
