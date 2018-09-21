# frozen_string_literal: true

module Engine
  module Operations
    module Multiply
      def operation_multiply(left, right)
        if left.is_a?(Numeric) && right.is_a?(Numeric)
          left.send(:*, right)
        elsif left.is_a?(String) && right.is_a?(Numeric)
          left.send(:*, right)
        else
          nil
        end
      end
    end
  end
end
