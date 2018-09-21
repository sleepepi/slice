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
    end
  end
end
