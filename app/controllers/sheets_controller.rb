class SheetsController < ApplicationController
  before_filter :authenticate_user!

  def send_email
    @sheet = Sheet.current.find(params[:id])

    @sheet.email_receipt(current_user, params[:to], params[:cc], params[:subject], params[:body])

    respond_to do |format|
      format.html { redirect_to @sheet, notice: 'Sheet receipt email was successfully sent.' }
      format.json { render json: @sheet }
    end
  end

  # GET /sheets
  # GET /sheets.json
  def index
    sheet_scope = Sheet.current

    @sheet_after = parse_date(params[:sheet_after])
    @sheet_before = parse_date(params[:sheet_before])

    sheet_scope = sheet_scope.sheet_before(@sheet_before) unless @sheet_before.blank?
    sheet_scope = sheet_scope.sheet_after(@sheet_after) unless @sheet_after.blank?

    ['design', 'project', 'site', 'user'].each do |filter|
      sheet_scope = sheet_scope.send("with_#{filter}", params["#{filter}_id".to_sym]) unless params["#{filter}_id".to_sym].blank?
    end

    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| sheet_scope = sheet_scope.search(search_term) }

    @order = params[:order]
    case params[:order] when 'sheets.site_id'
      sheet_scope = sheet_scope.order_by_site
    when 'sheets.site_id DESC'
      sheet_scope = sheet_scope.order_by_site_desc
    else
      @order = Sheet.column_names.collect{|column_name| "sheets.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "sheets.name"
      sheet_scope = sheet_scope.order(@order)
    end


    @sheet_count = sheet_scope.count

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
    @sheet = current_user.sheets.new(post_params)

    respond_to do |format|
      if @sheet.save

        create_variables!

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

        update_variables!

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
    params[:sheet] ||= {}

    unless params[:sheet][:project_id].blank? or params[:subject_code].blank? or params[:site_id].blank?
      subject = Subject.find_or_create_by_project_id_and_subject_code(params[:sheet][:project_id], params[:subject_code], { user_id: current_user.id, site_id: params[:site_id] })
    end

    params[:sheet][:subject_id] = (subject ? subject.id : nil)
    params[:sheet][:last_user_id] = current_user.id

    [:study_date].each do |date|
      params[:sheet][date] = parse_date(params[:sheet][date])
    end

    params[:sheet].slice(
      :name, :description, :design_id, :study_date, :project_id, :subject_id, :variable_ids, :last_user_id
    )
  end

  def create_variables!
    (params[:variables] || {}).each_pair do |variable_id, response|
      v = Variable.find_by_id(variable_id).dup
      response = [] if v.variable_type == 'checkbox' and response.blank?
      v.response = (v.variable_type == 'date') ? parse_date(response) : response
      v.project_id = @sheet.project_id
      v.user_id = current_user.id
      v.sheet_id = @sheet.id
      v.save
    end
  end

  def update_variables!
    (params[:variables] || {}).each_pair do |variable_id, response|
      v = @sheet.variables.find_by_id(variable_id)
      response = [] if v.variable_type == 'checkbox' and response.blank?
      v.response = (v.variable_type == 'date') ? parse_date(response) : response
      v.user_id = current_user.id
      v.save
    end
  end

end
