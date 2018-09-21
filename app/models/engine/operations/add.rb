# frozen_string_literal: true

module Engine
  module Operations
    module Add
      def operation_add(left, right)
        if left.is_a?(Numeric) && right.is_a?(Numeric)
          left.send(:+, right)
        elsif left.is_a?(String) && right.is_a?(String)
          left.send(:+, right)
        else
          nil
        end
      end
    end
  end
end
