class DesignsController < ApplicationController
  before_filter :authenticate_user!

  def selection
    @sheet = Sheet.new
    @design = Design.current.find_by_id(params[:sheet][:design_id])
  end

  def add_variable
    @design = Design.new(params[:design])
    @option = { variable_id: '' }
  end

  def variables
    @design = Design.new(params[:design])
  end

  # GET /designs
  # GET /designs.json
  def index
    design_scope = Design.current
    @order = Design.column_names.collect{|column_name| "designs.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "designs.name"
    design_scope = design_scope.order(@order)
    @designs = design_scope.page(params[:page]).per( 20 )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @designs }
    end
  end

  # GET /designs/1
  # GET /designs/1.json
  def show
    @design = Design.current.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @design }
    end
  end

  # GET /designs/new
  # GET /designs/new.json
  def new
    @design = Design.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @design }
    end
  end

  # GET /designs/1/edit
  def edit
    @design = Design.current.find(params[:id])
  end

  # POST /designs
  # POST /designs.json
  def create
    @design = current_user.designs.new(post_params)

    respond_to do |format|
      if @design.save
        format.html { redirect_to @design, notice: 'Design was successfully created.' }
        format.json { render json: @design, status: :created, location: @design }
      else
        format.html { render action: "new" }
        format.json { render json: @design.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /designs/1
  # PUT /designs/1.json
  def update
    @design = Design.current.find(params[:id])

    respond_to do |format|
      if @design.update_attributes(post_params)
        format.html { redirect_to @design, notice: 'Design was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @design.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /designs/1
  # DELETE /designs/1.json
  def destroy
    @design = Design.current.find(params[:id])
    @design.destroy

    respond_to do |format|
      format.html { redirect_to designs_url }
      format.json { head :no_content }
    end
  end

  private

  def post_params

    [].each do |date|
      params[:design][date] = parse_date(params[:design][date])
    end

    params[:design] ||= {}
    params[:design].slice(
      :name, :description, :project_id, :option_tokens
    )
  end
end
