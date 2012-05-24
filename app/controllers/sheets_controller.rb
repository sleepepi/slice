class SheetsController < ApplicationController
  before_filter :authenticate_user!

  # GET /sheets
  # GET /sheets.json
  def index
    sheet_scope = Sheet.current
    @order = Sheet.column_names.collect{|column_name| "sheets.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "sheets.name"
    sheet_scope = sheet_scope.order(@order)
    @sheets = sheet_scope.page(params[:page]).per( 20 )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @sheets }
    end
  end

  # GET /sheets/1
  # GET /sheets/1.json
  def show
    @sheet = Sheet.current.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sheet }
    end
  end

  # GET /sheets/new
  # GET /sheets/new.json
  def new
    @sheet = Sheet.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sheet }
    end
  end

  # GET /sheets/1/edit
  def edit
    @sheet = Sheet.current.find(params[:id])
  end

  # POST /sheets
  # POST /sheets.json
  def create
    if params[:sheet] and not params[:sheet][:project_id].blank? and not params[:subject_code].blank?
      params[:sheet][:subject_id] = Subject.find_or_create_by_project_id_and_subject_code(params[:sheet][:project_id], params[:subject_code], { user_id: current_user.id })
    end

    @sheet = current_user.sheets.new(post_params)

    respond_to do |format|
      if @sheet.save

        (params[:variables] || {}).each_pair do |variable_id, response|
          v = Variable.find_by_id(variable_id).dup
          v.response = (v.variable_type == 'date') ? parse_date(response) : response
          v.project_id = @sheet.project_id
          v.user_id = current_user.id
          v.sheet_id = @sheet.id
          v.save
        end

        format.html { redirect_to @sheet, notice: 'Sheet was successfully created.' }
        format.json { render json: @sheet, status: :created, location: @sheet }
      else
        format.html { render action: "new" }
        format.json { render json: @sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sheets/1
  # PUT /sheets/1.json
  def update
    @sheet = Sheet.current.find(params[:id])

    respond_to do |format|
      if @sheet.update_attributes(post_params)

        (params[:variables] || {}).each_pair do |variable_id, response|
          v = @sheet.variables.find_by_id(variable_id)
          v.response = (v.variable_type == 'date') ? parse_date(response) : response
          v.user_id = current_user.id
          v.save
        end

        format.html { redirect_to @sheet, notice: 'Sheet was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sheets/1
  # DELETE /sheets/1.json
  def destroy
    @sheet = Sheet.current.find(params[:id])
    @sheet.destroy

    respond_to do |format|
      format.html { redirect_to sheets_url }
      format.json { head :no_content }
    end
  end

  private

  def post_params

    [:study_date].each do |date|
      params[:sheet][date] = parse_date(params[:sheet][date])
    end

    params[:sheet] ||= {}
    params[:sheet].slice(
      :name, :description, :design_id, :study_date, :project_id, :subject_id, :variable_ids
    )
  end

end
