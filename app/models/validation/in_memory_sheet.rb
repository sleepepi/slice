# frozen_string_literal: true

# This class is used to merge stored database responses with newly entered
# responses in order to validate a sheet, sheet_variables, responses, and grids
# before saving back to database

module Validation
  class InMemorySheet
    # Concerns
    include Evaluatable

    attr_accessor :sheet_variables, :grids, :project, :variables, :design
    attr_accessor :errors

    def initialize(sheet)
      @sheet_variables = sheet.sheet_variables.includes(:variable, :responses).collect do |sv|
        InMemorySheetVariable.new(sv.variable, sv.response, sv.response_file, sv.responses)
      end
      @grids = Grid.where(sheet_variable_id: sheet.sheet_variables.select(:id)).includes(:variable, :responses, sheet_variable: :variable).collect do |g|
        InMemoryGrid.new(g.sheet_variable.variable, g.position, g.variable, g.response, g.response_file, g.responses)
      end
      @project = sheet.project
      @design = sheet.design
      @variables = []
      @errors = []
    end

    def merge_form_params!(variables_params)
      load_variables(variables_params)
      variables_params.each do |variable_id, response|
        variable = @variables.find { |v| v.id.to_s == variable_id.to_s }
        if variable
          load_grids!(variable, response)
          load_sheet_variable!(variable, response)
        end
      end
    end

    def load_grids!(variable, response)
      return unless variable.variable_type == 'grid'
      response.select! do |_key, vhash|
        vhash.values.count { |v| (!v.is_a?(Array) && v.present?) || (v.is_a?(Array) && v.join.present?) } > 0
      end
      response.each_pair { |k, v| }.each.with_index do |(key, variable_response_hash), position|
        variable_response_hash.each_pair do |grid_variable_id, res|
          grid_variable = @project.variables.find_by(id: grid_variable_id)
          load_grid!(variable, grid_variable, res, position) if grid_variable
        end
      end
    end

    def load_grid!(variable, grid_variable, res, position)
      grid = @grids.find { |g| g.parent_variable.id == variable.id && g.position == position && g.variable.id == grid_variable.id }
      unless grid
        grid = InMemoryGrid.new(variable, position, grid_variable)
        @grids << grid
      end
      grid = store_temp_response(grid_variable, grid, res)
      @grids.reject! { |g| g.parent_variable.id == variable.id && g.position == position && g.variable.id == grid_variable.id }
      @grids << grid
    end

    def load_sheet_variable!(variable, response)
      sheet_variable = @sheet_variables.find { |sv| sv.variable.id == variable.id }
      unless sheet_variable
        sheet_variable = InMemorySheetVariable.new(variable)
        @sheet_variables << sheet_variable
      end
      sheet_variable = store_temp_response(variable, sheet_variable, response)
      @sheet_variables.reject! { |sv| sv.variable.id == variable.id }
      @sheet_variables << sheet_variable
    end

    def show_design_option?(branching_logic)
      return true if branching_logic.to_s.strip.blank?
      result = exec_js_context.eval(expanded_branching_logic(branching_logic))
      result == false ? false : true
    rescue
      true
    end

    def visible_on_sheet?(variable)
      design_option = variable.design_options.find_by design_id: @design.id
      if design_option
        show_design_option?(design_option.branching_logic)
      else
        true
      end
    end

    def valid?
      return false unless @design
      @design.variables.each do |variable|
        if visible_on_sheet?(variable)
          sheet_variable = @sheet_variables.find { |sv| sv.variable.id == variable.id }
          if sheet_variable && variable.variable_type == 'grid'
            variable.grid_variable_ids.each do |grid_variable_id|
              grid_variable = @project.variables.find_by(id: grid_variable_id)
              if grid_variable
                grids = @grids.select { |g| g.parent_variable.id == variable.id && g.variable.id == grid_variable.id }
                grids.each do |grid|
                  value = grid_variable.response_to_value(grid ? grid.get_raw_response : nil)
                  validation_hash = grid_variable.value_in_range?(value)

                  case validation_hash[:status]
                  # when 'blank' # AND REQUIRED
                  #   @errors << "#{variable.name} can't be blank" if variable.requirement_on_design(@design) == 'required'
                  when 'invalid'
                    @errors << "#{variable.name} #{grid_variable.name} is invalid"
                  when 'out_of_range'
                    @errors << "#{variable.name} #{grid_variable.name} is out of range"
                  end
                end
              end
            end
          else
            value = variable.response_to_value(sheet_variable ? sheet_variable.get_raw_response : nil)
            validation_hash = variable.value_in_range?(value)

            case validation_hash[:status]
            when 'blank' # AND REQUIRED
              @errors << "#{variable.name} can't be blank" if variable.requirement_on_design(@design) == 'required'
            when 'invalid'
              @errors << "#{variable.name} is invalid"
            when 'out_of_range'
              @errors << "#{variable.name} is out of range"
            end
          end
        end
      end
      @errors.count == 0
    end

    private

    def load_variables(variables_params)
      @variables = @project.variables.where(id: variables_params.keys).to_a
    end

    def store_temp_response(variable, sheet_variable, response)
      if response.is_a?(ActionController::Parameters)
        response = response.to_unsafe_hash
      end
      variable.validator.store_temp_response(sheet_variable, response)
    end

    def expanded_branching_logic(branching_logic)
      branching_logic.to_s.gsub(/([a-zA-Z]+[\w]*)/) { |m| variable_javascript_value($1) }
    end

    def variable_javascript_value(variable_name)
      variable = @variables.find { |v| v.name == variable_name }
      if variable
        sheet_variable = @sheet_variables.find { |sv| sv.variable.id == variable.id }
        result = if sheet_variable
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
