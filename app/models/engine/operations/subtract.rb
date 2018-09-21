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
    end
  end
end
