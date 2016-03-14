# frozen_string_literal: true

# Allows project editors to add sections and questions to designs
class DesignOptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_editable_project
  before_action :redirect_without_project
  before_action :set_editable_design
  before_action :redirect_without_design

  before_action :set_new_design_option,
                only: [
                  :new_section, :new_variable, :new_existing_variable,
                  :create_section, :create_variable, :create_existing_variable
                ]
  before_action :set_design_option,
                only: [
                  :show, :edit, :edit_variable, :edit_domain, :update,
                  :update_domain, :destroy
                ]

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
    @section = current_user.sections.where(project_id: @project.id, design_id: @design.id).new(section_params)
    if @section.save
      @design_option.section_id = @section.id
      @design_option.save
    end
    if !@section.new_record? && !@design_option.new_record?
      @design.insert_new_design_option!(@design_option)
      render :index
    else
      render :new_section
    end
  end

  def create_variable
    @variable = current_user.variables.where(project_id: @project.id).new(variable_params)
    if @variable.save
      # if @variable.variable_type == 'grid' && params[:variable][:questions].present?
      #   @variable.create_variables_from_questions!(params[:variable][:questions])
      # end
      @design_option.variable_id = @variable.id
      @design_option.save
    end
    if !@variable.new_record? && !@design_option.new_record?
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
    @design_option.update(design_option_params)
    if @design_option.section && @design_option.section.update(section_params)
      render :show
    elsif @design_option.variable && @design_option.variable.update(variable_params)
      render :show
    else
      render :edit
    end
  end

  def update_domain
    @domain = @design_option.variable.domain || @project.domains.new(domain_params)
    if @domain.new_record? && @domain.save && @design_option.variable.update(domain_id: @domain.id)
      render :show
    elsif !@domain.new_record? && @domain.update(domain_params)
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
    section_order = params[:sections].to_s.split(',').collect(&:to_i)
    @design.reorder_sections(section_order, current_user)
    render 'update_order'
  end

  def update_option_order
    row_order = params[:rows].to_s.split(',').collect(&:to_i)
    @design.reorder_options(row_order, current_user)
    render 'update_order'
  end

  def reorder
  end

  private

  def set_editable_design
    @design = @project.designs.find_by_param params[:design_id]
  end

  def redirect_without_design
    empty_response_or_root_path(project_designs_path(@project)) unless @design
  end

  def set_new_design_option
    @design_option = @design.design_options.new(design_option_params_new)
  end

  def set_design_option
    @design_option = @design.design_options.find_by_id params[:id]
    redirect_without_design_option
  end

  def redirect_without_design_option
    empty_response_or_root_path(project_design_path(@project, @design)) unless @design_option
  end

  def design_option_params_new
    params.require(:design_option).permit(:variable_id, :position)
  end

  def design_option_params
    params[:design_option] ||= { blank: '1' }
    params.require(:design_option).permit(
      :branching_logic, :position, :required
    )
  end

  def section_params
    params.require(:section).permit(
      :name, :description, :level, :image, :image_cache, :remove_image
    )
  end

  def variable_params
    params[:variable] ||= { blank: '1' }
    parse_variable_dates
    params.require(:variable).permit(
      :name, :display_name, :description, :variable_type, :prepend, :append, :display_name_visibility,
      :show_current_button, :show_seconds, :hard_minimum, :hard_maximum, :soft_minimum, :soft_maximum,
      :date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum, :time_duration_format,
      :calculation, :format, :hide_calculation, :units, { grid_tokens: [:variable_id] }, :multiple_rows,
      { questions: [:question_name, :question_type] }, :default_row_number, :autocomplete_values, :alignment, :domain_id
    )
  end

  def parse_variable_dates
    parse_date_if_key_present(:variable, :date_hard_maximum)
    parse_date_if_key_present(:variable, :date_hard_minimum)
    parse_date_if_key_present(:variable, :date_soft_maximum)
    parse_date_if_key_present(:variable, :date_soft_minimum)
  end

  def domain_params
    params[:domain] ||= {}

    # Always update user_id to correctly track sheet transactions
    params[:domain][:user_id] = current_user.id # unless @domain

    params[:domain] = Domain.clean_option_tokens(params[:domain])

    params.require(:domain).permit(
      :name, :display_name, :description, :user_id,
      option_tokens: [:name, :value, :description, :missing_code, :option_index, :site_id]
    )
  end
end
