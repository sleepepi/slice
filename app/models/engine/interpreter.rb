# frozen_string_literal: true

# Engine that interprets the Slice Context Free Grammar.
module Engine
  class Interpreter
    attr_accessor :sobjects, :lexer, :parser, :subjects_count, :sobjects

    include ::Engine::Operations::All

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
          operation(node, :star, negative_one, right, result_name: "_unary_#{@operation_count += 1}")
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

      operation(node, token.token_type, left, right)
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
      elsif node.is_a?(::Engine::Expressions::Literal) && !node.value
        @sobjects = []
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
