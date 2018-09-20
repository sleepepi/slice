# frozen_string_literal: true

# Engine that interprets the Slice Context Free Grammar.
module Engine
  class Interpreter
    attr_accessor :sobjects, :lexer, :parser, :subjects_count, :sobjects

    def initialize(project, verbose: false)
      @project = project
      @sobjects = {}
      @operation_count = 0
      @verbose = verbose
      @subjects_count = 0
    end

    def run
      puts "Interpreter started..." if @verbose
      initialize_sobjects

      # Run through tree in LRN order.
      node = lrn(@parser.tree)
      if node.is_a?(::Engine::Expressions::Literal) && node.value == true
        # Do nothing
      elsif node.is_a?(::Engine::Expressions::VariableExp)
        # Do nothing
      elsif node.is_a?(::Engine::Expressions::EventExp)
        # Do nothing
      elsif node.is_a?(::Engine::Expressions::DesignExp)
        # Do nothing
      else
        filter(node)
      end

      @subjects_count = @project.subjects.where(id: @sobjects.collect { |key, sobject| sobject.subject_id }).count
    end

    def lrn(node)
      case node.class.to_s
      when "Engine::Expressions::Between"
        left = lrn(node.left)
        lower = lrn(node.lower)
        higher = lrn(node.higher)
        between_operation(node, left, lower, higher)
      when "Engine::Expressions::Binary"
        left = lrn(node.left)
        right = lrn(node.right)
        operation_helper(node, node.operator, left, right)
      when "Engine::Expressions::Grouping"
        lrn(node.expression)
      when "Engine::Expressions::Unary"
        right = lrn(node.right)
        case node.operator.token_type
        when :minus
          negative_one = ::Engine::Expressions::Literal.new(-1)
          operation(node, :*, negative_one, right, result_name: "_unary_#{@operation_count += 1}")
        when :plus
          right
        when :bang
          right # TODO: What would bang operator be used for here?
        end
      when "Engine::Expressions::Literal"
        node
      when "Engine::Expressions::VariableExp"
        node
      when "Engine::Expressions::DesignExp"
        node
      when "Engine::Expressions::EventExp"
        node
      end
    end

    def operation_helper(node, token, left, right)
      if token.token_type.in?([:and, :or, :xor])
        return boolean_operation(node, token.token_type, left, right)
      end

      symbol = case token.token_type
        when :bang_equal
          :!=
        when :greater_equal
          :>=
        when :less_equal
          :<=
        when :equal
          :==
        when :greater
          :>
        when :less
          :<
        when :minus
          :-
        when :plus
          :+
        when :slash
          :/
        when :star
          :*
        when :power
          :**
        else
          raise "Illegal operator: #{token.token_type}"
        end

      operation(node, symbol, left, right)
    end

    def initialize_sobjects
      load_sobjects
      load_sobjects_variables
    end


    def load_sobjects
      @project.subjects.pluck(:id).each do |subject_id|
        key = :"#{subject_id}"
        @sobjects[key] ||= Sobject.new(subject_id)
      end
    end

    def load_sobjects_variables
      @sobjects.each do |key, sobject|
        @parser.variable_exps.each do |variable_exp|
          sobject.add_value(variable_exp.storage_name, nil)
        end
      end
      @parser.variable_exps.each do |variable_exp|
        if variable_exp.event
          pluck_sobject_values_at_event(variable_exp)
        else
          pluck_sobject_values(variable_exp)
        end
      end
    end

    def pluck_sobject_values(variable_exp)
      variable = @project.variables.find_by(name: variable_exp.name)
      svs = SheetVariable
        .where(variable: variable)
        .left_outer_joins(:domain_option)
        .joins(:sheet).merge(Sheet.current)
        .pluck(:subject_id, domain_option_value_or_value)
      formatter = Formatters.for(variable)
      number_regex = Regexp.new(/^[-+]?[0-9]*(\.[0-9]+)?$/)
      svs.each do |subject_id, value|
        formatted_value = formatter.raw_response(value)
        if formatted_value.is_a?(String) && !(number_regex =~ formatted_value).nil?
          formatted_value = Float(formatted_value)
        end
        add_sobject_value(subject_id, variable_exp.storage_name, formatted_value)
      end
    end

    def pluck_sobject_values_at_event(variable_exp)
      variable = @project.variables.find_by(name: variable_exp.name)
      event = @project.events.find_by(slug: variable_exp.event.name)
      svs = SheetVariable
        .where(variable: variable)
        .left_outer_joins(:domain_option)
        .joins(:sheet).merge(Sheet.current)
        .where(sheets: { subject_event: SubjectEvent.where(event: event) })
        .pluck(:subject_id, domain_option_value_or_value)
      formatter = Formatters.for(variable)
      number_regex = Regexp.new(/^[-+]?[0-9]*(\.[0-9]+)?$/)
      svs.each do |subject_id, value|
        formatted_value = formatter.raw_response(value)
        if formatted_value.is_a?(String) && !(number_regex =~ formatted_value).nil?
          formatted_value = Float(formatted_value)
        end
        add_sobject_value(subject_id, variable_exp.storage_name, formatted_value)
      end
    end

    def add_sobject_value(subject_id, storage_name, value)
      key = :"#{subject_id}"
      @sobjects[key].add_value(storage_name, value) if @sobjects.key?(key)
    end

    def filter(node, value: true)
      if node.is_a?(::Engine::Expressions::Binary) && node.operator.boolean_operator?
        @sobjects.select! do |subject_id, sobject|
          sobject.get_value(node.result_name) == value
        end
      end
    end

    def between_operation(node, left, lower, higher)
      # TODO: Should these be added to the actual tree instead of generated in here?
      # BETWEEN operation is essentially three binary nodes in one.
      # perhaps expand this in the parser instead of adding a "between" operation itself.
      node_child1 = ::Engine::Expressions::Binary.new(left, ::Engine::Token.new(:greater_equal, auto: true), lower)
      node_child2 = ::Engine::Expressions::Binary.new(left, ::Engine::Token.new(:less_equal, auto: true), higher)

      r1 = operation(node_child1, :>=, left, lower)
      r2 = operation(node_child2, :<=, left, higher)

      result_name = "_betweenop_#{@operation_count += 1}"
      @sobjects.each do |subject_id, sobject|
        result = sobject.get_value(r1.result_name) && sobject.get_value(r2.result_name)
        if result
          Rails.logger.debug "REMO: r1.result_name: #{r1.result_name}"
          Rails.logger.debug "REMO: r2.result_name: #{r2.result_name}"
          Rails.logger.debug "REMO: r1.class: #{r1.class}"
          Rails.logger.debug "REMO: r2.class: #{r2.class}"
        end
        sobject.add_value(result_name, result)
      end
      node.result_name = result_name
      node
    end

    def boolean_operation(node, token_type, left, right, result_name: "_boolop_#{@operation_count += 1}")
      @sobjects.each do |subject_id, sobject|
        result = if token_type == :and
          sobject.get_value(left.result_name) && sobject.get_value(right.result_name)
        elsif token_type == :or
          sobject.get_value(left.result_name) || sobject.get_value(right.result_name)
        end
        sobject.add_value(result_name, result)
      end
      node.result_name = result_name
      node
    end

    # Allows "a", and "b" to be variable names OR numerics
    # operator is :+, :-, :/, :*, :**, :==, :>=, :<=, :>, :<
    def operation(node, operator, a, b, result_name: "_operation_#{@operation_count += 1}")
      if a.is_a?(::Engine::Expressions::Literal) && b.is_a?(::Engine::Expressions::Literal)
        operation_numbers(operator, a, b, result_name)
      elsif a.is_a?(::Engine::Expressions::Literal)
        operation_number_variable(operator, a, b, result_name)
      elsif b.is_a?(::Engine::Expressions::Literal)
        operation_variable_number(operator, a, b, result_name)
      else
        operation_variables(operator, a, b, result_name)
      end
      node.result_name = result_name
      node
    end

    def operation_variables(operator, v1, v2, result_name)
      v1_name = v1.is_a?(::Engine::Expressions::VariableExp) ? v1.storage_name : v1.result_name
      v2_name = v2.is_a?(::Engine::Expressions::VariableExp) ? v2.storage_name : v2.result_name

      @sobjects.each do |subject_id, sobject|
        result = if sobject.get_value(v1_name).class.in?([String, NilClass]) || sobject.get_value(v2_name).class.in?([String, NilClass])
          nil
        elsif operator == :/ && sobject.get_value(v2_name).zero?
          nil
        else
          sobject.get_value(v1_name).send(operator, sobject.get_value(v2_name))
        end
        sobject.add_value(result_name, result)
      end
    end

    def operation_variable_number(operator, v1, n2, result_name)
      v1_name = v1.is_a?(::Engine::Expressions::VariableExp) ? v1.storage_name : v1.result_name
      n2_value = n2.value

      if operator == :/ && n2_value.zero?
        @sobjects.each do |subject_id, sobject|
          sobject.add_value(result_name, nil)
        end
      else
        @sobjects.each do |subject_id, sobject|
          result = if sobject.get_value(v1_name).class.in?([String, NilClass])
            nil
          else
            sobject.get_value(v1_name).send(operator, n2_value)
          end
          sobject.add_value(result_name, result)
        end
      end
    end

    def operation_number_variable(operator, n1, v2, result_name)
      n1_value = n1.value
      v2_name = v2.is_a?(::Engine::Expressions::VariableExp) ? v2.storage_name : v2.result_name
      @sobjects.each do |subject_id, sobject|
        result = if sobject.get_value(v2_name).class.in?([String, NilClass])
          nil
        elsif operator == :/ && sobject.get_value(v2_name).zero?
          nil
        else
          n1_value.send(operator, sobject.get_value(v2_name))
        end
        sobject.add_value(result_name, result)
      end
    end

    def operation_numbers(operator, n1, n2, result_name)
      n1_value = n1.value
      n2_value = n2.value
      result = if operator == :/ && n2_value.zero?
        nil
      else
        n1_value.send(operator, n2_value)
      end
      @sobjects.each do |subject_id, sobject|
        sobject.add_value(result_name, result)
      end
    end

    private

    def domain_option_value_or_value(table: "sheet_variables")
      Arel.sql(
        "(CASE WHEN (NULLIF(domain_options.value, '') IS NULL) "\
        "THEN NULLIF(#{table}.value, '') "\
        "ELSE NULLIF(domain_options.value, '') END)"
      )
    end
  end
end
