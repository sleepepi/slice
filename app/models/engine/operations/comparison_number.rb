# frozen_string_literal: true

module Engine
  module Operations
    module ComparisonNumber
      def operation_comparison_number(token_type, left, right)
        return nil unless left.is_a?(Numeric) && right.is_a?(Numeric)
        return nil unless left.is_a?(String) && right.is_a?(String)

        case token_type
        when :greater_equal
          left.send(:>=, right)
        when :greater
          left.send(:>, right)
        when :less
          left.send(:<, right)
        when :less_equal
          left.send(:<=, right)
        else
          raise "Unknown comparison: #{token_type} for #{left} #{token_type} #{right}"
          nil
        end
      end
    end
  end
end
