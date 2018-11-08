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

      def operation_comparison_cell(token_type, left, right)
        if left.is_a?(::Engine::Cell) && right == :missing
          return check_missing(token_type, left, right)
        elsif right.is_a?(::Engine::Cell) && left == :missing
          return check_missing(token_type, right, left)
        end

        if left.is_a?(::Engine::Cell) && right == :present
          return check_present(token_type, left, right)
        elsif right.is_a?(::Engine::Cell) && left == :present
          return check_present(token_type, right, left)
        end

        if left.is_a?(::Engine::Cell) && right == :entered
          return check_entered(token_type, left, right)
        elsif right.is_a?(::Engine::Cell) && left == :entered
          return check_entered(token_type, right, left)
        end

        if left.is_a?(::Engine::Cell) && right == :unentered
          return check_unentered(token_type, left, right)
        elsif right.is_a?(::Engine::Cell) && left == :unentered
          return check_unentered(token_type, right, left)
        end

        left = left.value if left.is_a?(::Engine::Cell)
        right = right.value if right.is_a?(::Engine::Cell)
        operation_comparison(token_type, left, right)
      end

      def check_entered(token_type, left, right)
        if token_type == :equal
          !left.value.blank?
        elsif token_type == :bang_equal
          left.value.blank?
        else
          raise "Unknown comparison: #{token_type} for #{left} #{token_type} #{right}"
          nil
        end
      end

      def check_present(token_type, left, right)
        if token_type == :equal
          !left.missing? && !left.value.blank?
        elsif token_type == :bang_equal
          left.missing? || left.value.blank?
        else
          raise "Unknown comparison: #{token_type} for #{left} #{token_type} #{right}"
          nil
        end
      end

      def check_missing(token_type, left, right)
        if token_type == :equal
          left.missing? || left.value.blank?
        elsif token_type == :bang_equal
          !left.missing? && !left.value.blank?
        else
          raise "Unknown comparison: #{token_type} for #{left} #{token_type} #{right}"
          nil
        end
      end

      def check_unentered(token_type, left, right)
        if token_type == :equal
          left.value.blank?
        elsif token_type == :bang_equal
          !left.value.blank?
        else
          raise "Unknown comparison: #{token_type} for #{left} #{token_type} #{right}"
          nil
        end
      end
    end
  end
end
