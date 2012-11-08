class VariablesController < ApplicationController
  before_filter :authenticate_user!, except: [ :add_grid_row, :format_number, :typeahead ]

  def typeahead
    if current_user
      @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
      @variable = current_user.all_viewable_variables.find_by_id(params[:id])
    else
      @project = Project.current.find_by_id(params[:project_id])
      @sheet = @project.sheets.find_by_authentication_token(params[:sheet_authentication_token]) if @project and not params[:sheet_authentication_token].blank?
      @variable = @project.variables.find_by_id(params[:id]) if @project and @sheet
    end

    if @project and @variable and ['string'].include?(@variable.variable_type)
      render json: @variable.autocomplete_array
    else
      render json: []
    end
  end

  def format_number
    if current_user
      @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
      @variable = current_user.all_viewable_variables.find_by_id(params[:id])
    else
      @project = Project.current.find_by_id(params[:project_id])
      @sheet = @project.sheets.find_by_authentication_token(params[:sheet_authentication_token]) if @project and not params[:sheet_authentication_token].blank?
      @variable = @project.variables.find_by_id(params[:id]) if @project and @sheet
    end

    if @project and @variable
      unless @variable.format.blank?
        @result = @variable.format % params[:calculated_number] rescue params[:calculated_number]
      end

      render 'format_number'
    else
      render nothing: true
    end
  end

  def copy
    @project = current_user.all_projects.find_by_id(params[:project_id])
    variable = current_user.all_viewable_variables.find_by_id(params[:id])

    respond_to do |format|
      if @project and variable and @variable = current_user.variables.new(variable.copyable_attributes)
        @select_variables = current_user.all_viewable_variables.without_variable_type('grid').where(project_id: @project.id).order(:name).collect{|v| [v.name, v.id]}
        format.html { render 'new' }
        format.json { render json: @variable }
      elsif @project
        format.html { redirect_to project_variables_path(@project) }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  def add_grid_row
    if current_user
      @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
      @variable = current_user.all_viewable_variables.find_by_id(params[:id])
    else
      @project = Project.current.find_by_id(params[:project_id])
      @sheet = @project.sheets.find_by_authentication_token(params[:sheet_authentication_token]) if @project and not params[:sheet_authentication_token].blank?
      @variable = @project.variables.find_by_id(params[:id]) if @project and @sheet
    end
    render nothing: true unless @variable and @project
  end

  def add_grid_variable
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @select_variables = @project ? current_user.all_viewable_variables.without_variable_type(['grid', 'scale']).where(project_id: @project.id).order(:name).collect{|v| [v.name, v.id]} : []
    @grid_variable = { variable_id: '' }
  end

  def add_option
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @variable = Variable.new(params[:variable].except(:option_tokens))
    @option = { name: '', value: '', description: '' }
  end

  def options
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @variable = Variable.new(params[:variable])
  end

  # GET /variables
  # GET /variables.json
  def index
    @project = current_user.all_projects.find_by_id(params[:project_id])

    if @project
      current_user.pagination_set!('variables', params[:variables_per_page].to_i) if params[:variables_per_page].to_i > 0
      variable_scope = current_user.all_viewable_variables

      ['project', 'user'].each do |filter|
        variable_scope = variable_scope.send("with_#{filter}", params["#{filter}_id".to_sym]) unless params["#{filter}_id".to_sym].blank?
      end

      variable_scope = variable_scope.with_variable_type(params[:variable_type]) unless params[:variable_type].blank?

      @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
      @search_terms.each{|search_term| variable_scope = variable_scope.search(search_term) }

      @order = scrub_order(Variable, params[:order], 'variables.name')
      variable_scope = variable_scope.order(@order)

      @variable_count = variable_scope.count
      @variables = variable_scope.page(params[:page]).per( current_user.pagination_count('variables') )

      respond_to do |format|
        format.html # index.html.erb
        format.js
        format.json { render json: @variables }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /variables/1
  # GET /variables/1.json
  def show
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @variable = current_user.all_viewable_variables.find_by_id(params[:id])

    respond_to do |format|
      if @project and @variable
        format.html # show.html.erb
        format.js
        format.json { render json: @variable }
      elsif @project
        format.html { redirect_to project_variables_path(@project) }
        format.js { render nothing: true }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path }
        format.js { render nothing: true }
        format.json { head :no_content }
      end
    end
  end

  # GET /variables/new
  # GET /variables/new.json
  def new
    @variable = current_user.variables.new(project_id: params[:project_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @variable }
    end
  end

  # GET /variables/1/edit
  def edit
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @variable = current_user.all_variables.find_by_id(params[:id])
    @select_variables = current_user.all_viewable_variables.without_variable_type('grid').order(:project_id, :name).collect{|v| [v.name_with_project, v.id]}

    respond_to do |format|
      if @project and @variable
        format.html { render 'edit' }
        format.js { render 'popup' }
      elsif @project
        format.html { redirect_to project_variables_path(@project) }
        format.js { render nothing: true }
      else
        format.html { redirect_to root_path }
        format.js { render nothing: true }
      end
    end
  end

  # POST /variables
  # POST /variables.json
  def create
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @variable = current_user.variables.new(post_params)

    respond_to do |format|
      if @project
        if @variable.save
          format.html { redirect_to [@variable.project, @variable], notice: 'Variable was successfully created.' }
          format.json { render json: @variable, status: :created, location: @variable }
        else
          @select_variables = current_user.all_viewable_variables.without_variable_type('grid').where(project_id: @project.id).order(:name).collect{|v| [v.name, v.id]}
          format.html { render action: "new" }
          format.json { render json: @variable.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # PUT /variables/1
  # PUT /variables/1.json
  def update
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @variable = current_user.all_variables.find_by_id(params[:id])

    respond_to do |format|
      if @project
        if @variable
          if @variable.update_attributes(post_params)
            format.html { redirect_to [@variable.project, @variable], notice: 'Variable was successfully updated.' }
            format.js { render 'update' }
            format.json { head :no_content }
          else
            @select_variables = current_user.all_viewable_variables.without_variable_type('grid').where(project_id: @project.id).order(:name).collect{|v| [v.name, v.id]}
            format.html { render action: "edit" }
            format.js { render 'update' }
            format.json { render json: @variable.errors, status: :unprocessable_entity }
          end
        else
          format.html { redirect_to project_variables_path(@project) }
          format.js { render nothing: true }
          format.json { head :no_content }
        end
      else
        format.html { redirect_to root_path }
        format.js { render nothing: true }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /variables/1
  # DELETE /variables/1.json
  def destroy
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @variable = current_user.all_variables.find_by_id(params[:id])

    respond_to do |format|
      if @project
        @variable.destroy if @variable
        format.html { redirect_to project_variables_path(@project) }
        format.js { render 'destroy' }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path }
        format.js { render nothing: true }
        format.json { head :no_content }
      end
    end
  end

  private

  # def generate_csv(design_scope)
  #   @csv_string = CSV.generate do |csv|
  #     variable_ids = design_scope.collect{|d| d.variable_ids}.flatten
  #     variables = current_user.all_viewable_variables.where(id: variable_ids).order(:name)

  #     csv << ["Variable Name", "Variable Display Name", "Variable Header", "Variable Description", "Variable Type", "Variable Options", "Variable Project"]
  #     variables.each do |variable|
  #       row = [
  #               variable.name,
  #               variable.display_name,
  #               variable.header,
  #               variable.description,
  #               variable.variable_type,
  #               variable.options,
  #               variable.project.name
  #             ]
  #       csv << row
  #     end
  #   end
  #   send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
  #                          disposition: "attachment; filename=\"Designs DD #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.csv\""
  # end

  def post_params
    params[:variable] ||= {}

    params[:variable][:updater_id] = current_user.id

    params[:variable][:option_tokens] ||= {}

    if current_user.all_projects.pluck(:id).include?(params[:project_id].to_i)
      params[:variable][:project_id] = params[:project_id]
    else
      params[:variable][:project_id] = nil
    end

    [:date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum].each do |date|
      params[:variable][date] = parse_date(params[:variable][date])
    end

    params[:variable].slice(
      :name, :display_name, :description, :header, :variable_type, :option_tokens, :project_id, :updater_id, :display_name_visibility, :prepend, :append,
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
      :grid_tokens, :multiple_rows, :default_row_number,
      # For Autocomplete Strings
      :autocomplete_values,
      # Radio and Checkbox
      :alignment,
      # Scale
      :scale_type, :domain_id
    )
  end
end
