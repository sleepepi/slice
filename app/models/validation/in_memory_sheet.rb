# This class is used to merge stored database responses with newly entered
# responses in order to validate a sheet, sheet_variables, responses, and grids
# before saving back to database

module Validation
  class InMemoryResponse
    attr_accessor :value

    def initialize(value)
      @value = value
    end

  end

  class InMemorySheetVariable
    attr_accessor :variable, :variable_id, :response, :response_file, :responses

    def initialize(variable, variable_id, response = nil, response_file = nil, responses = [])
      @variable = variable
      @variable_id = variable_id
      @response = response
      @response_file = response_file
      @responses = responses.collect{|r| InMemoryResponse.new(r.value)}
    end

    def get_raw_response
      case @variable.variable_type when 'checkbox'
        @responses.collect(&:value)
      else
        @response
      end
    end
  end

  class InMemorySheet
    attr_accessor :sheet_variables, :project, :variables, :design

    def initialize(sheet)
      @sheet_variables = sheet.sheet_variables.collect{|sv| InMemorySheetVariable.new(sv.variable, sv.variable_id, sv.response, sv.response_file, sv.responses)}
      @project = sheet.project
      @design = sheet.design
      @variables = []
    end

    def merge_form_params!(variables_params)
      load_variables(variables_params)
      variables_params.each do |variable_id, response|
        variable = @variables.select{|v| v.id.to_s == variable_id.to_s}.first
        if variable
          sheet_variable = @sheet_variables.select{|sv| sv.variable_id == variable.id}.first
          unless sheet_variable
            sheet_variable = InMemorySheetVariable.new(variable, variable.id)
            @sheet_variables << sheet_variable
          end

          sheet_variable = store_temp_response(variable, sheet_variable, response)

          @sheet_variables.reject!{|sv| sv.variable_id == variable.id}
          @sheet_variables << sheet_variable
        end
      end
    end

    def show_variable?(branching_logic)
      return true if branching_logic.to_s.strip.blank?
      begin
        result = exec_js_context.eval(expanded_branching_logic(branching_logic))
        result == false ? false : true
      rescue => e
        true
      end
    end

    def visible_on_sheet?(variable)
      if option = variable.get_option_on_design(@design)
        show_variable?(option[:branching_logic])
      else
        true
      end
    end


    private

      def load_variables(variables_params)
        @variables = @project.variables.where(id: variables_params.keys).to_a
      end

      def store_temp_response(variable, sheet_variable, response)
        variable.validator.store_temp_response(sheet_variable, response)
      end

      def exec_js_context
        @exec_js_context ||= begin
          # Compiled CoffeeScript from designs.js.coffee
          index_of = "var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };"
          intersection_function = "this.intersection = function(a, b) { var value, _i, _len, _ref, _results; if (a.length > b.length) { _ref = [b, a], a = _ref[0], b = _ref[1]; } _results = []; for (_i = 0, _len = a.length; _i < _len; _i++) { value = a[_i]; if (__indexOf.call(b, value) >= 0) { _results.push(value); } } return _results; };"
          overlap_function = "this.overlap = function(a, b, c) { if (c == null) { c = 1; } return intersection(a, b).length >= c; };"
          ExecJS.compile(index_of + intersection_function + overlap_function)
        end
      end

      def expanded_branching_logic(branching_logic)
        branching_logic.to_s.gsub(/([a-zA-Z]+[\w]*)/){|m| variable_javascript_value($1)}
      end


      def variable_javascript_value(variable_name)
        variable = @variables.select{|v| v.name == variable_name}.first
        result = if variable
          result = if sheet_variable = @sheet_variables.select{|sv| sv.variable_id == variable.id}.first
            sheet_variable.get_raw_response
          else
            variable.variable_type == 'checkbox' ? [] : ''
          end
          result.to_json
        else
          variable_name
        end
      end

  end
end
