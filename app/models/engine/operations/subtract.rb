# frozen_string_literal: true

module Engine
  module Operations
    module Subtract
      def operation_subtract(left, right)
        if left.is_a?(Numeric) && right.is_a?(Numeric)
          left.send(:-, right)
        else
          nil
        end
      end

      def operation_subtract_cell(left, right)
        left = left.value if left.is_a?(::Engine::Cell)
        right = right.value if right.is_a?(::Engine::Cell)
        operation_subtract(left, right)
      end
    end
  end
end
