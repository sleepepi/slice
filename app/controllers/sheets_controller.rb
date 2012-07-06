class SheetsController < ApplicationController
  before_filter :authenticate_user!

  def project_selection
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    @subject = @project.subjects.find_by_subject_code(params[:subject_code]) if @project

    @site = @project.sites.find_by_id(@project.site_id_with_prefix(params[:subject_code])) if @project

    @subject_code_valid = if @site and params[:subject_code] <= @site.code_maximum.to_s and params[:subject_code].size <= @site.code_maximum.to_s.size and params[:subject_code] >= @site.code_minimum.to_s and params[:subject_code].size >= @site.code_minimum.to_s.size
      true
    else
      false
    end

    @disable_selection = (params[:select] != '1')
  end

  def send_email
    @sheet = Sheet.current.find(params[:id])

    html = render_to_string action: 'print', id: params[:id], layout: false

    pdf_attachment = begin
      kit = PDFKit.new(html)
      stylesheet_file = "#{Rails.root}/public/assets/application.css"
      kit.stylesheets << "#{Rails.root}/public/assets/application.css" if File.exists?(stylesheet_file)
      kit.to_pdf
    rescue
      nil
    end

    @sheet.email_receipt(current_user, params[:to], params[:cc], params[:subject], params[:body], pdf_attachment)

    respond_to do |format|
      format.html { redirect_to @sheet, notice: 'Sheet receipt email was successfully sent.' }
      format.json { render json: @sheet }
    end
  end

  # GET /sheets
  # GET /sheets.json
  def index
    sheet_scope = current_user.all_viewable_sheets

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
      @order = scrub_order(Sheet, params[:order], 'sheets.study_date DESC')
      sheet_scope = sheet_scope.order(@order)
    end


    @sheet_count = sheet_scope.count

    if params[:format] == 'csv'
      if @sheet_count == 0
        redirect_to sheets_path, alert: 'No data was exported since no sheets matched the specified filters.'
        return
      end
      @csv_string = CSV.generate do |csv|
        variable_names = sheet_scope.collect(&:variables).flatten.uniq.collect{|v| v.name}.uniq
        csv << ["Name", "Description", "Study Date", "Project", "Site", "Subject", "Creator"] + variable_names
        sheet_scope.each do |sheet|
          row = [sheet.name,
                  sheet.description,
                  sheet.study_date.blank? ? '' : sheet.study_date.strftime("%m-%d-%Y"),
                  sheet.project.name,
                  sheet.subject.site.name,
                  sheet.subject.name,
                  sheet.user.name]
          variable_names.each do |variable_name|
            row << if variable = sheet.variables.find_by_name(variable_name)
              variable.response_name(sheet)
            else
              ''
            end
          end
          csv << row
        end
      end
      send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
                            disposition: "attachment; filename=\"Sheets #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.csv\""
      return
    end

    @sheets = sheet_scope.page(params[:page]).per( 20 )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @sheets }
    end
  end

  def print
    @sheet = current_user.all_viewable_sheets.find_by_id(params[:id])
    if @sheet
      render layout: false
    else
      render nothing: true
    end
  end

  # GET /sheets/1
  # GET /sheets/1.json
  def show
    @sheet = current_user.all_viewable_sheets.find_by_id(params[:id])

    respond_to do |format|
      if @sheet
        format.html # show.html.erb
        format.json { render json: @sheet }
      else
        format.html { redirect_to sheets_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /sheets/new
  # GET /sheets/new.json
  def new
    @sheet = current_user.sheets.new(post_params)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sheet }
    end
  end

  # GET /sheets/1/edit
  def edit
    @sheet = current_user.all_sheets.find_by_id(params[:id])
    redirect_to sheets_path unless @sheet
  end

  # POST /sheets
  # POST /sheets.json
  def create
    @sheet = current_user.sheets.new(post_params)

    respond_to do |format|
      if @sheet.save
        update_variables!

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
    @sheet = current_user.all_sheets.find_by_id(params[:id])

    respond_to do |format|
      if @sheet
        if @sheet.update_attributes(post_params)
          update_variables!

          format.html { redirect_to @sheet, notice: 'Sheet was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @sheet.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to sheets_path }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /sheets/1
  # DELETE /sheets/1.json
  def destroy
    @sheet = current_user.all_sheets.find_by_id(params[:id])
    @sheet.destroy if @sheet

    respond_to do |format|
      format.html { redirect_to sheets_path }
      format.js { render 'destroy' }
      format.json { head :no_content }
    end
  end

  private

  def post_params
    params[:sheet] ||= {}

    params[:sheet][:project_id] = nil unless current_user.all_viewable_projects.pluck(:id).include?(params[:sheet][:project_id].to_i)

    unless params[:sheet][:project_id].blank? or params[:subject_code].blank? or params[:site_id].blank?
      subject = Subject.find_or_create_by_project_id_and_subject_code(params[:sheet][:project_id], params[:subject_code], { user_id: current_user.id, site_id: params[:site_id] })
      if subject.site and params[:subject_code] <= subject.site.code_maximum.to_s and params[:subject_code].size <= subject.site.code_maximum.to_s.size and params[:subject_code] >= subject.site.code_minimum.to_s and params[:subject_code].size >= subject.site.code_minimum.to_s.size
        subject.update_attribute :validated, true
      end
    end

    params[:sheet][:subject_id] = (subject ? subject.id : nil)
    params[:sheet][:last_user_id] = current_user.id

    [:study_date].each do |date|
      params[:sheet][date] = parse_date(params[:sheet][date])
    end

    params[:sheet].slice(
      :design_id, :study_date, :project_id, :subject_id, :variable_ids, :last_user_id
    )
  end

  # def create_variables!
  #   (params[:variables] || {}).each_pair do |variable_id, response|
  #     sv = @sheet.sheet_variables.create(variable_id: variable_id, user_id: current_user.id)
  #     response = [] if sv.variable.variable_type == 'checkbox' and response.blank?
  #     response = (sv.variable.variable_type == 'date') ? parse_date(response) : response
  #     sv.update_attribute :response, response
  #   end
  # end

  def update_variables!
    (params[:variables] || {}).each_pair do |variable_id, response|
      sv = @sheet.sheet_variables.find_or_create_by_variable_id(variable_id, { user_id: current_user.id } )
      response = [] if sv.variable.variable_type == 'checkbox' and response.blank?
      response = (sv.variable.variable_type == 'date') ? parse_date(response) : response
      sv.update_attribute :response, response
    end
  end

end
