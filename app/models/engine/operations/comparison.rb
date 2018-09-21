# frozen_string_literal: true

module Engine
  module Operations
    module Comparison
      def operation_comparison(token_type, left, right)
        if token_type == :equal
          left.send(:==, right)
        elsif token_type == :bang_equal
          left.send(:!=, right)
        else
          raise "Unknown comparison: #{token_type} for #{left} #{token_type} #{right}"
          nil
        end
      end
    end
  end
end
