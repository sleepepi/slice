# frozen_string_literal: true

module Engine
  module Operations
    module Divide
      def operation_divide(left, right)
        if left.is_a?(Numeric) && right.is_a?(Numeric) && !right.zero?
          left.send(:/, right)
        else
          nil
        end
      end

      def operation_divide_cell(left, right)
        left = left.value if left.is_a?(::Engine::Cell)
        right = right.value if right.is_a?(::Engine::Cell)
        operation_divide(left, right)
      end
    end
  end
end
