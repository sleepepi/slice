# frozen_string_literal: true

module Engine
  module Operations
    module Not
      def operation_not(node, right, result_name: "_not_#{@operation_count += 1}")
        if right.is_a?(::Engine::Expressions::Literal)
          result = !right.value
          @sobjects.each do |subject_id, sobject|
            sobject.initialize_cells(result_name)
            sobject.add_cell(result_name, ::Engine::Cell.new(result))
          end
        else
          cell_name = right.respond_to?(:storage_name) ? right.storage_name : right.result_name
          @sobjects.each do |subject_id, sobject|
            sobject.initialize_cells(result_name)
            cells = sobject.get_cells(cell_name)
            cells.each do |cell|
              result = !cell.value
              sobject.add_cell(result_name, ::Engine::Cell.new(result, seds: cell.seds))
            end
          end
        end
        node.result_name = result_name
        node
      end
    end
  end
end
