class DesignOptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :set_editable_design
  before_action :redirect_without_design

  before_action :set_new_design_option,           only: [ :new_section, :new_variable, :new_existing_variable, :create_section, :create_variable, :create_existing_variable ]
  before_action :set_design_option,               only: [ :show, :edit, :edit_variable, :edit_domain, :update, :update_domain, :destroy ]
  before_action :redirect_without_design_option,  only: [ :show, :edit, :edit_variable, :edit_domain, :update, :update_domain, :destroy ]

  def new
  end

  def new_section
    @section = @design.sections.new
  end

  def new_variable
    @variable = @project.variables.new(variable_params)
  end

  def new_existing_variable
  end

  def edit
  end

  def edit_variable
  end

  def edit_domain
    @domain = @design_option.variable.domain || @project.domains.new
  end

  def create_section
    @section = @design.sections.new(section_params)
    @section.project_id = @project.id
    @section.user_id = current_user.id
    if @section.save
      @design_option.section_id = @section.id
      @design_option.save
    end
    if !@section.new_record? and !@design_option.new_record?
      @design.insert_new_design_option!(@design_option)
      render :index
    else
      render :new_section
    end
  end

  def create_variable
    @variable = @design.variables.new(variable_params)
    @variable.project_id = @project.id
    @variable.user_id = current_user.id
    if @variable.save
      if @variable.variable_type == 'grid' and not params[:variable][:questions].blank?
        @variable.create_variables_from_questions!(params[:variable][:questions])
      end
      @design_option.variable_id = @variable.id
      @design_option.save
    end
    if !@variable.new_record? and !@design_option.new_record?
      @design.insert_new_design_option!(@design_option)
      render :index
    else
      render :new_variable
    end
  end

  def create_existing_variable
    if @design_option.save
      @design.insert_new_design_option!(@design_option)
      render :index
    else
      render :new_existing_variable
    end
  end

  def update
    if ((design_option_params and @design_option.update(design_option_params)) or !design_option_params) and ((@design_option.section and @design_option.section.update(section_params)) or (@design_option.variable and @design_option.variable.update(variable_params)))
      render :show
    else
      render :edit
    end
  end

  def update_domain
    @domain = @design_option.variable.domain
    @domain = @project.domains.new(domain_params) unless @domain
    if @design_option.variable and ((@domain.new_record? and @domain.save and @design_option.variable.update domain_id: @domain.id) or (!@domain.new_record? and @domain.update(domain_params)))
      render :show
    else
      render :edit_domain
    end
  end

  def destroy
    @design_option.destroy
    @design.recalculate_design_option_positions!
    render :index
  end

  def update_section_order
    section_order = params[:sections].to_s.split(',').collect{ |a| a.to_i }
    @design.reorder_sections(section_order, current_user)
    render 'update_order'
  end

  def update_option_order
    row_order = params[:rows].to_s.split(',').collect{ |a| a.to_i }
    @design.reorder_options(row_order, current_user)
    render 'update_order'
  end

  def reorder
  end

  private

    def set_editable_design
      @design = @project.designs.find_by_id(params[:design_id])
    end

    def redirect_without_design
      empty_response_or_root_path(project_designs_path(@project)) unless @design
    end

    def set_new_design_option
      @design_option = @design.design_options.new(design_option_params)
    end

    def set_design_option
      @design_option = @design.design_options.find_by_id params[:id]
    end

    def redirect_without_design_option
      empty_response_or_root_path(project_design_path(@project, @design)) unless @design_option
    end

    def design_option_params
      return unless params[:design_option]
      params.require(:design_option).permit(
        :variable_id, :section_id, :position, :required, :branching_logic
      )
    end

    def section_params
      params.require(:section).permit(
        :name, :description, :sub_section,
        :image, :image_cache, :remove_image
      )
    end

    def variable_params
      params[:variable] ||= { blank: '1' }
      [:date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum].each do |date|
        params[:variable][date] = parse_date(params[:variable][date]) if params[:variable].key?(date)
      end

      params.require(:variable).permit(
        :name, :display_name, :description, :variable_type, :display_name_visibility, :prepend, :append,
        # For Integers and Numerics
        :hard_minimum, :hard_maximum, :soft_minimum, :soft_maximum,
        # For Dates
        :date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum,
        # For Date, Time
        :show_current_button,
        # For Calculated Variables
        :calculation, :format,
        # For Integer, Numeric, and Calculated
        :units,
        # For Grid Variables
        { :grid_tokens => [ :variable_id ] },
        :multiple_rows, :default_row_number,
        # For Autocomplete Strings
        :autocomplete_values,
        # Radio and Checkbox
        :alignment, :domain_id
      )
    end

    def domain_params
      params[:domain] ||= {}

      # Always update user_id to correctly track sheet transactions
      params[:domain][:user_id] = current_user.id # unless @domain

      params[:domain] = Domain.clean_option_tokens(params[:domain])

      params.require(:domain).permit(
        :name, :display_name, :description, :user_id, { :option_tokens => [ :name, :value, :description, :missing_code, :option_index ] }
      )
    end

end
