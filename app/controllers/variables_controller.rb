class VariablesController < ApplicationController
  before_action :authenticate_user!, except: [ :add_grid_row, :format_number, :typeahead ]
  before_action :set_viewable_project, only: [ :cool_lookup ]
  before_action :set_editable_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy, :copy, :add_grid_variable ]
  before_action :redirect_without_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy, :copy, :add_grid_variable, :cool_lookup ]
  before_action :set_editable_variable, only: [ :show, :edit, :update, :destroy ]
  before_action :set_authenticatable_variable, only: [ :add_grid_row, :typeahead, :format_number ]
  before_action :redirect_without_variable, only: [ :show, :edit, :update, :destroy, :add_grid_row, :typeahead, :format_number ]

  def cool_lookup
    @variable = @project.variable_by_id(params[:variable_id])
  end

  def typeahead
    render json: ( ['string'].include?(@variable.variable_type) ? @variable.autocomplete_array.select{|i| (i.to_s.downcase.include?(params[:query].to_s.downcase))} : [] )
  end

  def format_number
    @result = if @variable.format.blank?
      params[:calculated_number]
    else
      @variable.format % params[:calculated_number] rescue params[:calculated_number]
    end
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

  def add_grid_row

  end

  def add_grid_variable
    @select_variables = current_user.all_viewable_variables.without_variable_type(['grid']).where(project_id: @project.id).order(:name).collect{|v| [v.name, v.id]}
    @grid_variable = { variable_id: '' }
  end

  # GET /variables
  # GET /variables.json
  def index
    @order = scrub_order(Variable, params[:order], 'variables.name')
    variable_scope = current_user.all_viewable_variables.search(params[:search]).order(@order)

    variable_scope = variable_scope.where(project_id: params[:project_id]) unless params[:project_id].blank?
    variable_scope = variable_scope.where(user_id: params[:user_id]) unless params[:user_id].blank?
    variable_scope = variable_scope.with_variable_type(params[:variable_type]) unless params[:variable_type].blank? or params[:variable_type] == 'on'

    @variables = variable_scope.page(params[:page]).per( 40 )
  end

  # GET /variables/1
  # GET /variables/1.json
  def show
  end

  # GET /variables/new
  # GET /variables/new.json
  def new
    @variable = current_user.variables.new(project_id: params[:project_id])

    respond_to do |format|
      format.html # new.html.erb
      format.js { render 'edit' }
      format.json { render json: @variable }
    end
  end

  # GET /variables/1/edit
  def edit
    @select_variables = current_user.all_viewable_variables.without_variable_type('grid').where(project_id: @project.id).order(:project_id, :name).collect{|v| [v.name, v.id]}
  end

  # POST /variables
  # POST /variables.json
  def create
    @variable = current_user.variables.new(variable_params)

    respond_to do |format|
      if @variable.save
        format.html { redirect_to [@variable.project, @variable], notice: 'Variable was successfully created.' }
        format.js { render 'update' }
        format.json { render action: 'show', status: :created, location: @variable }
      else
        @select_variables = current_user.all_viewable_variables.without_variable_type('grid').where(project_id: @project.id).order(:name).collect{|v| [v.name, v.id]}
        format.html { render action: 'new' }
        format.js { render 'update' }
        format.json { render json: @variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /variables/1
  # PUT /variables/1.json
  def update
    respond_to do |format|
      if @variable.update(variable_params)
        format.html { redirect_to [@variable.project, @variable], notice: 'Variable was successfully updated.' }
        format.js
        format.json { head :no_content }
      else
        @select_variables = current_user.all_viewable_variables.without_variable_type('grid').where(project_id: @project.id).order(:name).collect{|v| [v.name, v.id]}
        format.html { render action: 'edit' }
        format.js
        format.json { render json: @variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /variables/1
  # DELETE /variables/1.json
  def destroy
    @variable.destroy

    respond_to do |format|
      format.html { redirect_to project_variables_path(@project) }
      format.js
      format.json { head :no_content }
    end
  end

  private

    def set_editable_variable
      @variable = @project.variables.find_by_id(params[:id])
    end

    def set_authenticatable_variable
      if params[:sheet_authentication_token].blank? and @variable = Variable.current.find_by_id(params[:id]) and @variable.inherited_designs.select{|d| d.publicly_available}.count > 0
        @project = @variable.project
        return
      end

      if params[:sheet_authentication_token].blank? and current_user
        @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
        empty_response_or_root_path unless @project
        @variable = current_user.all_viewable_variables.find_by_id(params[:id])
      else
        @project = Project.current.find_by_id(params[:project_id])
        @sheet = @project.sheets.find_by_authentication_token(params[:sheet_authentication_token]) if @project and not params[:sheet_authentication_token].blank?
        @variable = @project.variables.find_by_id(params[:id]) if @project and @sheet
      end
    end

    def redirect_without_variable
      empty_response_or_root_path(project_variables_path(@project)) unless @variable
    end

    def variable_params
      params[:variable] ||= {}

      params[:variable][:updater_id] = current_user.id

      # params[:variable][:option_tokens] ||= {}

      params[:variable][:project_id] = @project.id

      params[:variable][:domain_id] = nil if params[:variable][:variable_type] and not Variable::TYPE_DOMAIN.include?(params[:variable][:variable_type])

      [:date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum].each do |date|
        params[:variable][date] = parse_date(params[:variable][date])
      end

      params.require(:variable).permit(
        :name, :display_name, :description, :variable_type, :project_id, :updater_id, :display_name_visibility, :prepend, :append,
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

end
