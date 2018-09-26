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
            sobject.initialize_cells(result_name)
            sobject.add_cell(result_name, ::Engine::Cell.new(result))
          end
        elsif left.is_a?(::Engine::Expressions::Literal)
          l = !!left.value
          @sobjects.each do |subject_id, sobject|
            sobject.initialize_cells(result_name)
            cells = sobject.get_cells(right.result_name)
            cells.each do |cell|
              result = l.send(operator, !!cell.value)
              sobject.add_cell(result_name, ::Engine::Cell.new(result, seds: cell.seds))
            end
          end
        elsif right.is_a?(::Engine::Expressions::Literal)
          r = !!right.value
          @sobjects.each do |subject_id, sobject|
            sobject.initialize_cells(result_name)
            cells = sobject.get_cells(left.result_name)
            cells.each do |cell|
              result = r.send(operator, !!cell.value)
              sobject.add_cell(result_name, ::Engine::Cell.new(result, seds: cell.seds))
            end
          end
        else
          @sobjects.each do |subject_id, sobject|
            sobject.initialize_cells(result_name)
            cellsl = sobject.get_cells(left.result_name)
            cellsr = sobject.get_cells(right.result_name)
            cellsl.each do |cl|
              cellsr.each do |cr|
                next if ::Engine::Sed.skip?(cl.seds, cr.seds)
                result = (!!cl.value).send(operator, !!cr.value)
                # Trim out SEDs that don't contribute to the overall expression. # TODO: This may invalidate "negative" equality expressions.
                # seds = result ? (cl.seds + cr.seds).uniq { |sed| sed.values } : []
                seds = (cl.seds + cr.seds).uniq { |sed| sed.values }
                sobject.add_cell(result_name, ::Engine::Cell.new(result, seds: seds))
              end
            end
          end
        end
      end
    end
  end
end
