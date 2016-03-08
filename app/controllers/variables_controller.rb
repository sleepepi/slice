# frozen_string_literal: true

class VariablesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [:cool_lookup]
  before_action :set_editable_project, only: [:index, :show, :new, :edit, :create, :update, :destroy, :copy, :add_grid_variable, :restore]
  before_action :redirect_without_project, only: [:index, :show, :new, :edit, :create, :update, :destroy, :copy, :add_grid_variable, :restore, :cool_lookup]
  before_action :set_restorable_variable, only: [:restore]
  before_action :set_editable_variable, only: [:show, :edit, :update, :destroy]
  before_action :redirect_without_variable, only: [:show, :edit, :update, :destroy, :restore]

  def cool_lookup
    @variable = @project.variable_by_id params[:variable_id]
  end

  def copy
    variable = current_user.all_viewable_variables.find_by_id(params[:id])
    @variable = current_user.variables.new(variable.copyable_attributes) if variable

    if @variable
      @select_variables = current_user.all_viewable_variables.without_variable_type('grid').where(project_id: @project.id).order(:name).collect{|v| [v.name, v.id]}
      render 'new'
    else
      redirect_to project_variables_path(@project)
    end
  end

  def add_grid_variable
    @select_variables = current_user.all_viewable_variables.without_variable_type(['grid']).where(project_id: @project.id).order(:name).collect{|v| [v.name, v.id]}
    @grid_variable = { variable_id: '' }
  end

  # GET /variables
  def index
    @order = scrub_order(Variable, params[:order], 'variables.name')
    variable_scope = current_user.all_viewable_variables.search(params[:search]).order(@order)
    variable_scope = variable_scope.where(project_id: @project.id)
    variable_scope = variable_scope.where(user_id: params[:user_id]) unless params[:user_id].blank?
    variable_scope = variable_scope.with_variable_type(params[:variable_type]) unless params[:variable_type].blank? or params[:variable_type] == 'on'
    @variables = variable_scope.page(params[:page]).per( 40 )
  end

  # GET /variables/1
  def show
  end

  # GET /variables/new
  def new
    @variable = current_user.variables.new(project_id: @project.id)
  end

  # GET /variables/1/edit
  def edit
    @select_variables = current_user.all_viewable_variables.without_variable_type('grid').where(project_id: @project.id).order(:project_id, :name).collect { |v| [v.name, v.id] }
  end

  # POST /variables
  def create
    @variable = current_user.variables.new(variable_params)
    if @variable.save
      url = if params[:continue].to_s == '1'
              new_project_variable_path(@variable.project)
            else
              [@variable.project, @variable]
            end
      redirect_to url, notice: 'Variable was successfully created.'
    else
      @select_variables = current_user.all_viewable_variables.without_variable_type('grid').where(project_id: @project.id).order(:name).collect { |v| [v.name, v.id] }
      render :new
    end
  end

  # PUT /variables/1
  def update
    if @variable.update(variable_params)
      url = if params[:continue].to_s == '1'
              new_project_variable_path(@variable.project)
            else
              [@variable.project, @variable]
            end
      redirect_to url, notice: 'Variable was successfully updated.'
    else
      @select_variables = current_user.all_viewable_variables.without_variable_type('grid').where(project_id: @project.id).order(:name).collect { |v| [v.name, v.id] }
      render :edit
    end
  end

  # DELETE /variables/1
  def destroy
    @variable.destroy

    respond_to do |format|
      format.html { redirect_to project_variables_path(@project) }
      format.js
    end
  end

  def restore
    @variable.update deleted: false
    redirect_to [@project, @variable]
  end

  private

  def set_editable_variable
    @variable = @project.variables.find_by_id(params[:id])
  end

  def set_restorable_variable
    @variable = Variable.where(project_id: @project.id, deleted: true).find_by_id(params[:id])
  end

  def redirect_without_variable
    empty_response_or_root_path(project_variables_path(@project)) unless @variable
  end

  def variable_params
    params[:variable] ||= {}

    params[:variable][:updater_id] = current_user.id

    # params[:variable][:option_tokens] ||= {}

    params[:variable][:project_id] = @project.id

    params[:variable][:domain_id] = nil if params[:variable][:variable_type] && !Variable::TYPE_DOMAIN.include?(params[:variable][:variable_type])

    [:date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum].each do |date|
      params[:variable][date] = parse_date(params[:variable][date])
    end

    params.require(:variable).permit(
      :name, :display_name, :description, :variable_type, :project_id,
      :updater_id, :display_name_visibility, :prepend, :append,
      # For Integers and Numerics
      :hard_minimum, :hard_maximum, :soft_minimum, :soft_maximum,
      # For Dates
      :date_hard_maximum, :date_hard_minimum, :date_soft_maximum,
      :date_soft_minimum,
      # For Date, Time
      :show_current_button,
      # For Time
      :show_seconds,
      # For Time Duration
      :time_duration_format,
      # For Calculated Variables
      :calculation, :format, :hide_calculation,
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
end
