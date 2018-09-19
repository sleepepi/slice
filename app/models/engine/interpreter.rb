# frozen_string_literal: true

# Engine that interprets the Slice Context Free Grammar.
module Engine
  class Interpreter
    attr_accessor :sobjects, :lexer, :parser, :tree, :variable_names, :subjects_count, :sobjects

    def initialize(project, verbose: false)
      @project = project
      @sobjects = {}
      @operation_count = 0
      @variable_names = []
      @verbose = verbose
      @subjects_count = 0
    end

    def run
      puts "Interpreter started..." if @verbose
      load_sobjects

      # Run through tree in LRN order.
      result = lrn(@tree)
      filter(result)
      @subjects_count = @project.subjects.where(id: @sobjects.collect { |key, sobject| sobject.subject_id }).count
    end

    def lrn(node)
      case node.class.to_s
      when "Engine::Expressions::Between"
        left = lrn(node.left)
        lower = lrn(node.lower)
        higher = lrn(node.higher)
        between_operation(left, lower, higher)
      when "Engine::Expressions::Binary"
        left = lrn(node.left)
        right = lrn(node.right)
        operation_helper(node.operator, left, right)
      when "Engine::Expressions::Grouping"
        lrn(node.expression)
      when "Engine::Expressions::Literal"
        return node.value
      when "Engine::Expressions::Unary"
        right = lrn(node.right)
        case node.operator.token_type
        when :minus
          operation(:*, -1, right)
        when :plus
          right
        when :bang
          right # TODO: What would bang operator be used for here?
        end
      when "Engine::Expressions::VariableExp"
        return node.name
      end
    end

    def operation_helper(token, left, right)
      if token.token_type.in?([:and, :or])
        return boolean_operation(token.token_type, left, right)
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
        else
          raise "Illegal operator: #{token.token_type}"
        end

      operation(symbol, left, right)
    end

    def add_sobject_value(subject_id, variable_name, value)
      key = :"#{subject_id}"
      @sobjects[key] ||= Sobject.new(subject_id)
      @sobjects[key].add_value(variable_name, value)
    end

    def load_sobjects
      variables = @project.variables.where(name: @variable_names)
      variables.each do |variable|
        pluck_sobject_values(variable)
      end
    end

    def filter(result_name, value: true)
      @sobjects.select! do |subject_id, sobject|
        sobject.get_value(result_name) == value
      end
    end

    def between_operation(left, lower, higher, result_name: "_operation_#{@operation_count += 1}")
      r1 = operation(:>=, left, lower)
      r2 = operation(:<=, left, higher)

      @sobjects.each do |subject_id, sobject|
        result = sobject.get_value(r1) && sobject.get_value(r2)
        sobject.add_value(result_name, result)
      end
      result_name
    end

    def boolean_operation(token_type, left, right, result_name: "_boolop_#{@operation_count += 1}")
      @sobjects.each do |subject_id, sobject|
        result = if token_type == :and
          sobject.get_value(left) && sobject.get_value(right)
        elsif token_type == :or
          sobject.get_value(left) || sobject.get_value(right)
        end
        sobject.add_value(result_name, result)
      end
      result_name
    end

    # Allows "a", and "b" to be variable names OR numerics
    # operator is :+, :-, :/, :*, :**, :==, :>=, :<=, :>, :<
    def operation(operator, a, b, result_name: "_operation_#{@operation_count += 1}")
      if a.is_a?(String) && b.is_a?(String)
        operation_variables(operator, a, b, result_name)
      elsif a.is_a?(String)
        operation_variable_number(operator, a, b, result_name)
      elsif b.is_a?(String)
        operation_number_variable(operator, a, b, result_name)
      else
        operation_numbers(operator, a, b, result_name)
      end
      result_name
    end

    def operation_variables(operator, v1_name, v2_name, result_name)
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

    def operation_variable_number(operator, v1_name, b, result_name)
      if operator == :/ && b.zero?
        @sobjects.each do |subject_id, sobject|
          sobject.add_value(result_name, nil)
        end
      else
        @sobjects.each do |subject_id, sobject|
          result = if sobject.get_value(v1_name).class.in?([String, NilClass])
            nil
          else
            sobject.get_value(v1_name).send(operator, b)
          end
          sobject.add_value(result_name, result)
        end
      end
    end

    def operation_number_variable(operator, a, v2_name, result_name)
      @sobjects.each do |subject_id, sobject|
        result = if sobject.get_value(v2_name).class.in?([String, NilClass])
          nil
        elsif operator == :/ && sobject.get_value(v2_name).zero?
          nil
        else
          a.send(operator, sobject.get_value(v2_name))
        end
        sobject.add_value(result_name, result)
      end
    end

    def operation_numbers(operator, a, b, result_name)
      result = if operator == :/ && b.zero?
        nil
      else
        a.send(operator, b)
      end
      @sobjects.each do |subject_id, sobject|
        sobject.add_value(result_name, result)
      end
    end

    def pluck_sobject_values(variable)
      svs = SheetVariable
        .where(variable: variable)
        .left_outer_joins(:domain_option)
        .joins(:sheet)
        .pluck(:subject_id, domain_option_value_or_value)
      formatter = Formatters.for(variable)
      number_regex = Regexp.new(/^[-+]?[0-9]*(\.[0-9]+)?$/)
      svs.each do |subject_id, value|
        formatted_value = formatter.raw_response(value)
        if formatted_value.is_a?(String) && !(number_regex =~ formatted_value).nil?
          formatted_value = Float(formatted_value)
        end
        add_sobject_value(subject_id, variable.name, formatted_value)
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
