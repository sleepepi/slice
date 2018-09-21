# frozen_string_literal: true

module Engine
  module Operations
    module Boolean
      def boolean_operation(node, token_type, left, right, result_name: "_boolop_#{@operation_count += 1}")
        case token_type
        when :and
          # Note: `&` is the bitwise operator, however, both left and right are
          #       made "truthy" using the !! cast in boolean_generic()
          boolean_generic(node, token_type, left, right, result_name, :&)
        when :or
          # Note: `|` is the bitwise operator, however, both left and right are
          #       made "truthy" using the !! cast in boolean_generic()
          boolean_generic(node, token_type, left, right, result_name, :|)
        when :xor
          boolean_generic(node, token_type, left, right, result_name, :^)
        end
        node.result_name = result_name
        node
      end

      def boolean_generic(node, token_type, left, right, result_name, operator)
        if left.is_a?(::Engine::Expressions::Literal) && right.is_a?(::Engine::Expressions::Literal)
          result = (!!left.value).send(operator, !!right.value)
          @sobjects.each do |subject_id, sobject|
            sobject.add_value(result_name, result)
          end
        elsif left.is_a?(::Engine::Expressions::Literal)
          l = !!left.value
          @sobjects.each do |subject_id, sobject|
            result = l.send(operator, !!sobject.get_value(right.result_name))
            sobject.add_value(result_name, result)
          end
        elsif right.is_a?(::Engine::Expressions::Literal)
          r = !!right.value
          @sobjects.each do |subject_id, sobject|
            result = r.send(operator, !!sobject.get_value(left.result_name))
            sobject.add_value(result_name, result)
          end
        else
          @sobjects.each do |subject_id, sobject|
            result = (!!sobject.get_value(left.result_name)).send(operator, !!sobject.get_value(right.result_name))
            sobject.add_value(result_name, result)
          end
        end
      end
    end
  end
end
