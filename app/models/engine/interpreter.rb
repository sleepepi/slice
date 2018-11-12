# frozen_string_literal: true

# Engine that interprets the Slice Context Free Grammar.
module Engine
  class Interpreter
    attr_accessor :sobjects, :lexer, :parser, :subjects_count, :sobjects, :final

    include ::Engine::Operations::All

    def initialize(project, verbose: false)
      @project = project
      @sobjects = {}
      @operation_count = 0
      @verbose = verbose
      @subjects_count = 0
      @final = nil
    end

    def run
      puts "Interpreter started..." if @verbose
      initialize_sobjects

      # Run through tree in LRN order.
      node = lrn(@parser.tree)
      filter(node)
      @final = node.result_name

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
          operation_not(node, right)
        end
      when "Engine::Expressions::Literal"
        node
      when "Engine::Expressions::IdentifierVariable"
        node
      when "Engine::Expressions::IdentifierDesign"
        node
      when "Engine::Expressions::IdentifierEvent"
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
      load_sobjects_identifiers
    end

    def load_sobjects
      @project.subjects.pluck(:id).each do |subject_id|
        key = :"#{subject_id}"
        @sobjects[key] ||= Sobject.new(subject_id)
      end
    end

    def load_sobjects_identifiers
      @sobjects.each do |key, sobject|
        @parser.identifiers.each do |identifier|
          sobject.initialize_cells(identifier.storage_name)
        end
      end
      list = []
      @parser.identifier_variables.each do |identifier|
        entry = [identifier.name, identifier.event&.name]
        next if entry.in?(list)
        list << entry
        pluck_sobject_values(identifier)
      end

      list = []
      @parser.identifier_designs.each do |identifier|
        entry = [identifier.name, identifier.event&.name]
        next if entry.in?(list)
        list << entry
        pluck_sobject_designs(identifier)
      end

      list = []
      @parser.identifier_events.each do |identifier|
        entry = identifier.name
        next if entry.in?(list)
        list << entry
        pluck_sobject_events(identifier)
      end
    end

    def pluck_sobject_values(identifier)
      variable = @project.variables.find_by(name: identifier.name)
      event = @project.events.find_by(slug: identifier.event.name) if identifier.event
      hash = {}
      hash[:variable] = variable
      hash[:sheets] = { subject_event: SubjectEvent.where(event: event) } if event
      klass = (variable.variable_type == "checkbox" ? Response : SheetVariable)
      values = klass
        .left_outer_joins(:domain_option).joins(:sheet).merge(
          Sheet.current.left_outer_joins(:adverse_event).where("sheets.adverse_event_id IS NULL or adverse_events.deleted = ?", false)
        ).where(hash).order(:sheet_id)
        .pluck("sheets.subject_id", :sheet_id, :design_id, domain_option_value_or_value(table: klass.table_name), :missing_code)
      formatter = Formatters.for(variable)
      integer_regex = Regexp.new(/^[-+]?[1-9][0-9]*$/)
      decimal_regex = Regexp.new(/^[-+]?[0-9]*(\.)?[0-9]+$/)
      values.each do |subject_id, sheet_id, design_id, value, missing_code|
        formatted_value = formatter.raw_response(value)
        if formatted_value.is_a?(String) && (formatted_value == "0" || !(integer_regex =~ formatted_value).nil?)
          formatted_value = Integer(formatted_value)
        elsif formatted_value.is_a?(String) && !(decimal_regex =~ formatted_value).nil?
          formatted_value = Float(formatted_value)
        end
        cell = ::Engine::Cell.new(formatted_value, subject_id: subject_id, missing_code: missing_code)
        cell.add_sed(sheet_id: sheet_id, event_id: event&.id, design_id: design_id)
        add_sobject_cell(subject_id, identifier.storage_name, cell)
      end
    end

    def pluck_sobject_designs(identifier)
      design = @project.designs.find_by(slug: identifier.name)
      event = @project.events.find_by(slug: identifier.event.name) if identifier.event
      hash = {}
      hash[:design] = design
      hash[:subject_event] = SubjectEvent.where(event: event) if event
      sheets = @project.sheets.where(hash).order(:id).pluck(:subject_id, :id, :percent, :missing)
      sheets.each do |subject_id, sheet_id, percent, missing|
        cell = ::Engine::Cell.new(true, subject_id: subject_id, coverage: percent, missing_code: missing)
        cell.add_sed(sheet_id: sheet_id, event_id: event&.id, design_id: design.id)
        add_sobject_cell(subject_id, identifier.storage_name, cell)
      end
    end

    def pluck_sobject_events(identifier)
      event = @project.events.find_by(slug: identifier.name)
      hash = { subject_event: SubjectEvent.where(event: event) }
      sheets = @project.sheets.left_outer_joins(:subject_event).where(hash).order(:id).pluck(:subject_id, :id, :design_id, "subject_events.unblinded_percent") # TODO: Change based on current user permissions
      sheets.each do |subject_id, sheet_id, design_id, percent|
        cell = ::Engine::Cell.new(true, subject_id: subject_id, coverage: percent)
        cell.add_sed(sheet_id: sheet_id, event_id: event.id, design_id: design_id)
        add_sobject_cell(subject_id, identifier.storage_name, cell)
      end
    end

    def add_sobject_cell(subject_id, storage_name, cell)
      key = :"#{subject_id}"
      @sobjects[key].add_cell(storage_name, cell) if @sobjects.key?(key)
    end

    def filter(node)
      if node.is_a?(::Engine::Expressions::Binary) && node.operator.boolean_operator?
        @sobjects.select! do |subject_id, sobject|
          sobject.cells[node.result_name] = sobject.get_cells(node.result_name).select { |c| c.value }
          sobject.cells[node.result_name].present?
        end
      elsif node.is_a?(::Engine::Expressions::Literal) && !node.value
        @sobjects = []
      end
    end

    def sheets
      @project.sheets.where(id: sheet_ids)
    end

    def sheet_ids
      @sobjects.collect do |_, sobject|
        sobject.get_cells(@final).collect do |cell|
          cell.seds.collect(&:sheet_id)
        end
      end.flatten
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
