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
    end
  end
end
