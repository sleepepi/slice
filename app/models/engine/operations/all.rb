# frozen_string_literal: true

module Engine
  module Operations
    module All
      include ::Engine::Operations::Not
      include ::Engine::Operations::Boolean
      include ::Engine::Operations::Add
      include ::Engine::Operations::Subtract
      include ::Engine::Operations::Multiply
      include ::Engine::Operations::Divide
      include ::Engine::Operations::Exponent
      include ::Engine::Operations::Comparison
      include ::Engine::Operations::ComparisonNumber

      def operation(node, token_type, a, b, result_name: "_operation_#{@operation_count += 1}")
        if token_type.in?([:bang_equal, :equal, :greater, :greater_equal, :less, :less_equal])
          result_name = "_comparison_#{@operation_count - 1}"
        end

        if a.is_a?(::Engine::Expressions::Literal) && b.is_a?(::Engine::Expressions::Literal)
          operation_literals(node, token_type, a, b, result_name)
        elsif a.is_a?(::Engine::Expressions::Literal)
          operation_literal_identifier(node, token_type, a, b, result_name)
        elsif b.is_a?(::Engine::Expressions::Literal)
          operation_identifier_literal(node, token_type, a, b, result_name)
        elsif a.is_a?(::Engine::Expressions::IdentifierSubject) && b.is_a?(::Engine::Expressions::Randomized)
          operation_randomized(node, token_type, b, a, result_name)
        elsif a.is_a?(::Engine::Expressions::Randomized) && b.is_a?(::Engine::Expressions::IdentifierSubject)
          operation_randomized(node, token_type, a, b, result_name)
        else
          operation_identifiers(node, token_type, a, b, result_name)
        end
        node.result_name = result_name
        node
      end

      private

      def operation_identifiers(node, token_type, v1, v2, result_name)
        v1_name = v1.respond_to?(:storage_name) ? v1.storage_name : v1.result_name
        v2_name = v2.respond_to?(:storage_name) ? v2.storage_name : v2.result_name
        @sobjects.each do |subject_id, sobject|
          sobject.initialize_cells(result_name)
          cells1 = sobject.get_cells(v1_name)
          cells2 = sobject.get_cells(v2_name)
          cells1.each do |c1|
            cells2.each do |c2|
              next if ::Engine::Sed.skip?(c1.seds, c2.seds)
              result = operation_generic(token_type, c1, c2)
              seds = (c1.seds + c2.seds).uniq { |sed| sed.values }
              sobject.add_cell(result_name, ::Engine::Cell.new(result, seds: seds))
            end
          end
        end
      end

      def operation_randomized(node, token_type, v1, v2, result_name)
        v1_name = v1.respond_to?(:storage_name) ? v1.storage_name : v1.result_name
        @sobjects.each do |subject_id, sobject|
          sobject.initialize_cells(result_name)
          cells1 = sobject.get_cells(v1_name)
          cells1.each do |c1|
            result = operation_generic(token_type, c1, :present)
            sobject.add_cell(result_name, ::Engine::Cell.new(result, seds: c1.seds))
          end
        end
      end

      def operation_identifier_literal(node, token_type, v1, n2, result_name)
        v1_name = v1.respond_to?(:storage_name) ? v1.storage_name : v1.result_name
        n2_value = n2.value
        @sobjects.each do |subject_id, sobject|
          sobject.initialize_cells(result_name)
          cells1 = sobject.get_cells(v1_name)
          cells1.each do |c1|
            result = operation_generic(token_type, c1, n2_value)
            sobject.add_cell(result_name, ::Engine::Cell.new(result, seds: c1.seds))
          end
        end
      end

      def operation_literal_identifier(node, token_type, n1, v2, result_name)
        n1_value = n1.value
        v2_name = v2.respond_to?(:storage_name) ? v2.storage_name : v2.result_name
        @sobjects.each do |subject_id, sobject|
          sobject.initialize_cells(result_name)
          cells2 = sobject.get_cells(v2_name)
          cells2.each do |c2|
            result = operation_generic(token_type, n1_value, c2)
            sobject.add_cell(result_name, ::Engine::Cell.new(result, seds: c2.seds))
          end
        end
      end

      def operation_literals(node, token_type, n1, n2, result_name)
        n1_value = n1.value
        n2_value = n2.value
        result = operation_generic(token_type, n1_value, n2_value)
        @sobjects.each do |subject_id, sobject|
          sobject.initialize_cells(result_name)
          sobject.add_cell(result_name, ::Engine::Cell.new(result))
        end
      end

      def operation_generic(token_type, left, right)
        case token_type
        when :plus
          operation_add_cell(left, right)
        when :minus
          operation_subtract_cell(left, right)
        when :star
          operation_multiply_cell(left, right)
        when :slash
          operation_divide_cell(left, right)
        when :power
          operation_exponent_cell(left, right)
        when :bang_equal, :equal
          operation_comparison_cell(token_type, left, right)
        when :greater_equal, :less_equal, :greater, :less
          operation_comparison_number_cell(token_type, left, right)
        else
          raise "Unknown operator"
          nil
        end
      end
    end
  end
end
