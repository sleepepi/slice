class VariablesController < ApplicationController
  before_filter :authenticate_user!

  def copy
    variable = Variable.current.find(params[:id])
    @variable = current_user.variables.new(variable.copyable_attributes)
    render 'new'
  end

  def add_option
    @variable = Variable.new(params[:variable])
    @option = { name: '', value: '', description: '' }
  end

  def options
    @variable = Variable.new(params[:variable])
  end

  # GET /variables
  # GET /variables.json
  def index
    variable_scope = Variable.current.where( sheet_id: nil )

    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| variable_scope = variable_scope.search(search_term) }

    @order = Variable.column_names.collect{|column_name| "variables.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "variables.name"
    variable_scope = variable_scope.order(@order)
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
    @variable = Variable.current.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @variable }
    end
  end

  # GET /variables/new
  # GET /variables/new.json
  def new
    @variable = Variable.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @variable }
    end
  end

  # GET /variables/1/edit
  def edit
    @variable = Variable.current.find(params[:id])
  end

  # POST /variables
  # POST /variables.json
  def create
    @variable = current_user.variables.new(post_params)

    respond_to do |format|
      if @variable.save
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
    @variable = Variable.current.find(params[:id])

    respond_to do |format|
      if @variable.update_attributes(post_params)
        format.html { redirect_to @variable, notice: 'Variable was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @variable.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /variables/1
  # DELETE /variables/1.json
  def destroy
    @variable = Variable.current.find(params[:id])
    @variable.destroy

    respond_to do |format|
      format.html { redirect_to variables_url }
      format.json { head :no_content }
    end
  end

  private

  def post_params

    [].each do |date|
      params[:variable][date] = parse_date(params[:variable][date])
    end

    params[:variable] ||= {}
    params[:variable].slice(
      :name, :description, :header, :variable_type, :option_tokens, :response, :minimum, :maximum
    )
  end
end
