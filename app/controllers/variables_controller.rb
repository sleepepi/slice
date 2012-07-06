class VariablesController < ApplicationController
  before_filter :authenticate_user!

  def copy
    variable = current_user.all_viewable_variables.find_by_id(params[:id])
    respond_to do |format|
      if variable and @variable = current_user.variables.new(variable.copyable_attributes)
        format.html { render 'new' }
        format.json { render json: @variable }
      else
        format.html { redirect_to variables_path }
        format.json { head :no_content }
      end
    end
  end

  def add_option
    @variable = Variable.new(params[:variable].except(:option_tokens))
    @option = { name: '', value: '', description: '' }
  end

  def options
    @variable = Variable.new(params[:variable])
  end

  # GET /variables
  # GET /variables.json
  def index
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
    @variables = variable_scope.page(params[:page]).per( 20 )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @variables }
    end
  end

  # GET /variables/1
  # GET /variables/1.json
  def show
    @variable = current_user.all_viewable_variables.find_by_id(params[:id])

    respond_to do |format|
      if @variable
        format.html # show.html.erb
        format.js
        format.json { render json: @variable }
      else
        format.html { redirect_to variables_path }
        format.js { render nothing: true }
        format.json { head :no_content }
      end
    end
  end

  # GET /variables/new
  # GET /variables/new.json
  def new
    @variable = current_user.variables.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @variable }
    end
  end

  # GET /variables/1/edit
  def edit
    @variable = current_user.all_variables.find_by_id(params[:id])
    redirect_to variables_path unless @variable
  end

  # POST /variables
  # POST /variables.json
  def create
    post_params_copy = post_params
    @variable = current_user.variables.new(post_params_copy)

    respond_to do |format|
      if @variable.saveable?(current_user, post_params_copy) and @variable.save
        format.html { redirect_to @variable, notice: 'Variable was successfully created.' }
        format.json { render json: @variable, status: :created, location: @variable }
      else
        format.html { render action: "new" }
        format.json { render json: @variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /variables/1
  # PUT /variables/1.json
  def update
    post_params_copy = post_params
    @variable = current_user.all_variables.find_by_id(params[:id])

    respond_to do |format|
      if @variable
        if @variable.saveable?(current_user, post_params_copy) and @variable.update_attributes(post_params_copy)
          format.html { redirect_to @variable, notice: 'Variable was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @variable.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to variables_path }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /variables/1
  # DELETE /variables/1.json
  def destroy
    @variable = current_user.all_variables.find_by_id(params[:id])
    @variable.destroy if @variable

    respond_to do |format|
      format.html { redirect_to variables_path }
      format.js { render 'destroy' }
      format.json { head :no_content }
    end
  end

  private

  def post_params
    params[:variable] ||= {}

    params[:variable][:option_tokens] ||= {}

    [:date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum].each do |date|
      params[:variable][date] = parse_date(params[:variable][date])
    end

    params[:variable].slice(
      :name, :display_name, :description, :header, :variable_type, :option_tokens, :project_id,
      # For Integers and Numerics
      :hard_minimum, :hard_maximum, :soft_minimum, :soft_maximum,
      # For Dates
      :date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum,
      # For Calculated Variables
      :calculation
    )
  end
end
