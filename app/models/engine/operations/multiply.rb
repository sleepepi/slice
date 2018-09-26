# frozen_string_literal: true

module Engine
  module Operations
    module Multiply
      def operation_multiply(left, right)
        if left.is_a?(Numeric) && right.is_a?(Numeric)
          left.send(:*, right)
        elsif left.is_a?(String) && right.is_a?(Numeric) && right.positive?
          left.send(:*, right)
        else
          nil
        end
      end

      def operation_multiply_cell(left, right)
        left = left.value if left.is_a?(::Engine::Cell)
        right = right.value if right.is_a?(::Engine::Cell)
        operation_multiply(left, right)
      end
    end
  end
end
