# frozen_string_literal: true

# Allows project editors to view and modify project variables.
class VariablesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_viewable_project_or_redirect, only: :search
  before_action :find_editable_project_or_redirect, only: [
    :index, :show, :new, :edit, :create, :update, :destroy, :copy,
    :add_grid_variable, :restore
  ]
  before_action :find_restorable_variable_or_redirect, only: :restore
  before_action :find_editable_variable_or_redirect, only: [
    :show, :edit, :update, :destroy
  ]

  layout "layouts/full_page_sidebar_dark"

  # GET /projects/:project_id/variables/1/copy
  def copy
    variable = viewable_variables.find_by(id: params[:id])
    @variable = current_user.variables.new(variable.copyable_attributes) if variable
    if @variable
      render :new
    else
      redirect_to project_variables_path(@project)
    end
  end

  # POST /projects/:project_id/variables/add_grid_variable.js
  def add_grid_variable
    @child_grid_variable = @project.grid_variables.new
  end

  # GET /projects/:project_id/variables
  def index
    @order = scrub_order(Variable, params[:order], "variables.name")
    variable_scope = viewable_variables.search_any_order(params[:search]).order(@order)
    variable_scope = variable_scope.where(user_id: params[:user_id]) if params[:user_id].present?
    variable_scope = variable_scope.where(variable_type: params[:variable_type]) if params[:variable_type].present?
    @variables = variable_scope.page(params[:page]).per(20)
  end

  # GET /projects/:project_id/search.json
  def search
    variable_scope = viewable_variables.where(variable_type: %w(dropdown checkbox radio string integer numeric date calculated imperial_height imperial_weight))
                                       .where("name ILIKE (?)", "#{params[:q]}%")
                                       .order(:name).limit(10)
    render json: variable_scope.pluck(:name)
  end

  # # GET /projects/:project_id/variables/1
  # def show
  # end

  # GET /projects/:project_id/variables/new
  def new
    @variable = current_user.variables.where(project_id: @project.id).new
  end

  # # GET /projects/:project_id/variables/1/edit
  # def edit
  # end

  # POST /projects/:project_id/variables
  def create
    @variable = current_user.variables.where(project_id: @project.id).new(variable_params)
    if @variable.save
      @variable.create_variables_from_questions!
      @variable.update_grid_tokens!
      redirect_to [@variable.project, @variable], notice: "Variable was successfully created."
    else
      render :new
    end
  end

  # PATCH /projects/:project_id/variables/1
  def update
    if @variable.save_translation!(variable_params)
      url = [@variable.project, @variable, language: params[:language]]
      redirect_to url, notice: "Variable was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /projects/:project_id/variables/1
  def destroy
    @variable.destroy
    respond_to do |format|
      format.html { redirect_to project_variables_path(@project) }
      format.js
    end
  end

  # POST /projects/:project_id/variables/1/restore
  def restore
    @variable.update deleted: false
    redirect_to [@project, @variable]
  end

  private

  def viewable_variables
    @project.variables
  end

  def find_editable_variable_or_redirect
    @variable = @project.variables.find_by(id: params[:id])
    redirect_without_variable
  end

  def find_restorable_variable_or_redirect
    @variable = Variable.where(project_id: @project.id, deleted: true).find_by(id: params[:id])
    redirect_without_variable
  end

  def redirect_without_variable
    return if @variable
    empty_response_or_root_path(project_variables_path(@project))
  end

  def variable_params
    params[:variable] ||= {}
    params[:variable][:updater_id] = current_user.id
    clean_domain_id
    parse_variable_dates
    params.require(:variable).permit(
      :name, :display_name, :description, :variable_type,
      :updater_id, :display_layout, :prepend, :append, :field_note,
      # For Integers and Numerics
      :hard_minimum, :hard_maximum, :soft_minimum, :soft_maximum,
      # For Dates
      :date_hard_maximum, :date_hard_minimum, :date_soft_maximum,
      :date_soft_minimum, :date_format, :disallow_future_dates,
      # For Date, Time of Day
      :show_current_button,
      # For Time of Day
      :time_of_day_format, :show_seconds,
      # For Time Duration
      :time_duration_format,
      # For Calculated Variables
      :calculation, :calculated_format, :hide_calculation,
      # For Integer, Numeric, and Calculated
      :units,
      # For Grid Variables
      { grid_tokens: [:variable_id] },
      :multiple_rows, :default_row_number,
      # For Autocomplete Strings
      :autocomplete_values,
      # Radio and Checkbox
      :alignment, :domain_id
    )
  end

  def clean_domain_id
    if params[:variable][:variable_type] && !Variable::TYPE_DOMAIN.include?(params[:variable][:variable_type])
      params[:variable][:domain_id] = nil
    end
  end

  def parse_variable_dates
    parse_date_if_key_present(:variable, :date_hard_maximum)
    parse_date_if_key_present(:variable, :date_hard_minimum)
    parse_date_if_key_present(:variable, :date_soft_maximum)
    parse_date_if_key_present(:variable, :date_soft_minimum)
  end
end
