# frozen_string_literal: true

module Engine
  module Operations
    module All
      include ::Engine::Operations::Boolean
      include ::Engine::Operations::Add
      include ::Engine::Operations::Subtract
      include ::Engine::Operations::Multiply
      include ::Engine::Operations::Divide
      include ::Engine::Operations::Exponent
      include ::Engine::Operations::Comparison
      include ::Engine::Operations::ComparisonNumber

      def operation(node, token_type, a, b, result_name: "_operation_#{@operation_count += 1}")
        if a.is_a?(::Engine::Expressions::Literal) && b.is_a?(::Engine::Expressions::Literal)
          operation_literals(node, token_type, a, b, result_name)
        elsif a.is_a?(::Engine::Expressions::Literal)
          operation_literal_identifier(node, token_type, a, b, result_name)
        elsif b.is_a?(::Engine::Expressions::Literal)
          operation_identifier_literal(node, token_type, a, b, result_name)
        else
          operation_identifiers(node, token_type, a, b, result_name)
        end
        node.result_name = result_name
        node
      end

      private

      def operation_generic(token_type, left, right)
        case token_type
        when :plus
          operation_add(left, right)
        when :minus
          operation_subtract(left, right)
        when :star
          operation_multiply(left, right)
        when :slash
          operation_divide(left, right)
        when :power
          operation_exponent(left, right)
        when :bang_equal, :equal
          operation_comparison(token_type, left, right)
        when :greater_equal, :less_equal, :greater, :less
          operation_comparison_number(token_type, left, right)
        else
          raise "Unknown operator"
          nil
        end
      end

      def operation_identifiers(node, token_type, v1, v2, result_name)
        v1_name = v1.is_a?(::Engine::Expressions::VariableExp) ? v1.storage_name : v1.result_name
        v2_name = v2.is_a?(::Engine::Expressions::VariableExp) ? v2.storage_name : v2.result_name
        @sobjects.each do |subject_id, sobject|
          result = operation_generic(token_type, sobject.get_value(v1_name), sobject.get_value(v2_name))
          sobject.add_value(result_name, result)
        end
      end

      def operation_identifier_literal(node, token_type, v1, n2, result_name)
        v1_name = v1.is_a?(::Engine::Expressions::VariableExp) ? v1.storage_name : v1.result_name
        n2_value = n2.value
        @sobjects.each do |subject_id, sobject|
          result = operation_generic(token_type, sobject.get_value(v1_name), n2_value)
          sobject.add_value(result_name, result)
        end
      end

      def operation_literal_identifier(node, token_type, n1, v2, result_name)
        n1_value = n1.value
        v2_name = v2.is_a?(::Engine::Expressions::VariableExp) ? v2.storage_name : v2.result_name
        @sobjects.each do |subject_id, sobject|
          result = operation_generic(token_type, n1_value, sobject.get_value(v2_name))
          sobject.add_value(result_name, result)
        end
      end

      def operation_literals(node, token_type, n1, n2, result_name)
        n1_value = n1.value
        n2_value = n2.value
        result = operation_generic(token_type, n1_value, n2_value)
        @sobjects.each do |subject_id, sobject|
          sobject.add_value(result_name, result)
        end
      end
    end
  end
end
