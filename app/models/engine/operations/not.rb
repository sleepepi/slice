# frozen_string_literal: true

module Engine
  module Operations
    module Not
      def operation_not(node, right, result_name: "_not_#{@operation_count += 1}")
        if right.is_a?(::Engine::Expressions::Literal)
          result = !right.value
          @sobjects.each do |subject_id, sobject|
            sobject.add_cell(result_name, ::Engine::Cell.new(result))
          end
        else
          cell_name = right.is_a?(::Engine::Expressions::VariableExp) ? right.storage_name : right.result_name
          @sobjects.each do |subject_id, sobject|
            result = !sobject.get_cell(cell_name).value
            sobject.add_cell(result_name, ::Engine::Cell.new(result))
          end
        end
        node.result_name = result_name
        node
      end
    end
  end
end
