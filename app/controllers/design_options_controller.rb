# frozen_string_literal: true

# Allows project editors to add sections and questions to designs.
class DesignOptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect
  before_action :find_editable_design_or_redirect
  before_action :find_new_design_option, only: [
    :new_section, :new_variable, :new_existing_variable, :create_section,
    :create_variable, :create_existing_variable
  ]
  before_action :find_design_option_or_redirect, only: [
    :show, :edit, :edit_variable, :edit_domain, :update, :update_domain,
    :destroy
  ]

  # # GET /designs/:design_id/design_options/new
  # def new
  # end

  # GET /designs/:design_id/design_options/new_section
  def new_section
    @section = @design.sections.new
  end

  # GET /designs/:design_id/design_options/new_variable
  def new_variable
    @variable = @project.variables.new(variable_params)
  end

  # # GET /designs/:design_id/design_options/new_existing_variable
  # def new_existing_variable
  # end

  # # GET /designs/:design_id/design_options/1/edit
  # def edit
  # end

  # # GET /designs/:design_id/design_options/1/edit_variable
  # def edit_variable
  # end

  # GET /designs/:design_id/design_options/1/edit_domain
  def edit_domain
    @domain = @design_option.variable.domain || @project.domains.new
  end

  # POST /designs/:design_id/design_options/create_section
  def create_section
    @section = current_user.sections.where(project_id: @project.id, design_id: @design.id).new(section_params)
    @design_option.branching_logic = params[:design_option][:branching_logic] if params[:design_option] && params[:design_option][:branching_logic].present?
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

  # POST /designs/:design_id/design_options/create_variable
  def create_variable
    @variable = current_user.variables.where(project_id: @project.id).new(variable_params)
    if @variable.save
      @variable.create_variables_from_questions!
      @variable.update_grid_tokens!
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

  # POST /designs/:design_id/design_options/create_existing_variable
  def create_existing_variable
    if @design_option.save
      @design.insert_new_design_option!(@design_option)
      render :index
    else
      render :new_existing_variable
    end
  end

  # PATCH /designs/:design_id/design_options/1
  def update
    @design_option.update(design_option_params)
    if World.translate_language?
      if @design_option.save_translation!(section_params, variable_params)
        render :show
      else
        render :edit
      end
    elsif @design_option.section && @design_option.section.update(section_params)
      render :show
    elsif @design_option.variable && @design_option.variable.update(variable_params)
      @design_option.variable.update_grid_tokens!
      render :show
    else
      render :edit
    end
  end

  # PATCH /designs/:design_id/design_options/1/update_domain
  def update_domain
    @domain = @design_option.variable.domain || @project.domains.where(user: current_user).new(domain_params)
    if @domain.new_record? && @domain.save && @design_option.variable.update(domain_id: @domain.id)
      @domain.update_option_tokens!
      render :show
    elsif !@domain.new_record? && @domain.update(domain_params)
      @domain.update_option_tokens!
      render :show
    else
      render :edit_domain
    end
  end

  # DELETE /designs/:design_id/design_options/1
  def destroy
    @design_option.destroy
    @design.recalculate_design_option_positions!
    render :index
  end

  # POST /designs/:design_id/design_options/update_section_order
  def update_section_order
    row_order = params[:rows].to_s.split(",").collect(&:to_i)
    @design.reorder_sections(row_order, current_user)
    render :update_order
  end

  # POST /designs/:design_id/design_options/update_option_order
  def update_option_order
    row_order = params[:rows].to_s.split(",").collect(&:to_i)
    @design.reorder_options(row_order, current_user)
    render :update_order
  end

  private

  def find_editable_design_or_redirect
    @design = @project.designs.find_by_param(params[:design_id])
    redirect_without_design
  end

  def redirect_without_design
    empty_response_or_root_path(project_designs_path(@project)) unless @design
  end

  def find_new_design_option
    @design_option = @design.design_options.new(design_option_params_new)
  end

  def find_design_option_or_redirect
    @design_option = @design.design_options.find_by(id: params[:id])
    redirect_without_design_option
  end

  def redirect_without_design_option
    empty_response_or_root_path(project_design_path(@project, @design)) unless @design_option
  end

  def design_option_params_new
    params.require(:design_option).permit(:variable_id, :position)
  end

  def design_option_params
    params[:design_option] ||= { blank: "1" }
    params.require(:design_option).permit(
      :branching_logic, :position, :requirement
    )
  end

  def section_params
    params[:section] ||= { blank: "1" }
    params.require(:section).permit(
      :name, :description, :level, :image, :image_cache, :remove_image
    )
  end

  def variable_params
    params[:variable] ||= { blank: "1" }
    parse_variable_dates
    params.require(:variable).permit(
      :name, :display_name, :description, :variable_type, :prepend, :append, :field_note, :display_layout,
      :show_current_button, :show_seconds, :hard_minimum, :hard_maximum, :soft_minimum, :soft_maximum, :domain_id,
      :date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum, :date_format, :time_of_day_format,
      :time_duration_format, :calculation, :calculated_format, :hide_calculation, :units, :multiple_rows,
      :default_row_number, :alignment,
      { grid_tokens: [:variable_id] }, { questions: [:question_name, :question_type] }, :autocomplete_values
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
    params[:domain] = Domain.clean_option_tokens(params[:domain])
    params.require(:domain).permit(
      :name, :display_name, :description, :user_id,
      option_tokens: [:name, :value, :description, :missing_code, :site_id, :domain_option_id, :archived]
    )
  end
end
