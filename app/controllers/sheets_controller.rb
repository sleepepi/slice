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
    @sheet = current_user.all_sheets.find_by_id(params[:id])

    if @sheet
      html = render_to_string action: 'print', id: params[:id], layout: false

      pdf_attachment = nil

      if params[:pdf_attachment] == '1'
        pdf_attachment = begin
          kit = PDFKit.new(html)
          stylesheet_file = "#{Rails.root}/public/assets/application.css"
          kit.stylesheets << "#{Rails.root}/public/assets/application.css" if File.exists?(stylesheet_file)
          kit.to_pdf
        rescue
          nil
        end
      end

      @sheet.email_receipt(current_user, params[:to], params[:cc], params[:subject], params[:body], pdf_attachment)

      respond_to do |format|
        format.html { redirect_to @sheet, notice: 'Sheet receipt email was successfully sent.' }
        format.json { render json: @sheet }
      end
    else
      respond_to do |format|
        format.html { redirect_to sheets_path, alert: 'You do not have sufficient privileges to send a sheet receipt email.' }
        format.json { render head :no_content }
      end
    end
  end

  # GET /sheets
  # GET /sheets.json
  def index
    current_user.pagination_set!('sheets', params[:sheets_per_page].to_i) if params[:sheets_per_page].to_i > 0
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
    case params[:order] when 'sheets.site_name'
      sheet_scope = sheet_scope.order_by_site_name
    when 'sheets.site_name DESC'
      sheet_scope = sheet_scope.order_by_site_name_desc
    when 'sheets.design_name'
      sheet_scope = sheet_scope.order_by_design_name
    when 'sheets.design_name DESC'
      sheet_scope = sheet_scope.order_by_design_name_desc
    when 'sheets.subject_code'
      sheet_scope = sheet_scope.order_by_subject_code
    when 'sheets.subject_code DESC'
      sheet_scope = sheet_scope.order_by_subject_code_desc
    when 'sheets.project_name'
      sheet_scope = sheet_scope.order_by_project_name
    when 'sheets.project_name DESC'
      sheet_scope = sheet_scope.order_by_project_name_desc
    when 'sheets.user_name'
      sheet_scope = sheet_scope.order_by_user_name
    when 'sheets.user_name DESC'
      sheet_scope = sheet_scope.order_by_user_name_desc
    else
      @order = scrub_order(Sheet, params[:order], 'sheets.study_date DESC')
      sheet_scope = sheet_scope.order(@order)
    end


    @sheet_count = sheet_scope.count

    if params[:format] == 'labeled_csv'
      if @sheet_count == 0
        redirect_to sheets_path, alert: 'No data was exported since no sheets matched the specified filters.'
        return
      end
      generate_csv(sheet_scope, false)
      return
    elsif params[:format] == 'raw_csv'
      if @sheet_count == 0
        redirect_to sheets_path, alert: 'No data was exported since no sheets matched the specified filters.'
        return
      end
      generate_csv(sheet_scope, true)
      return
    end

    if params[:format] == 'scope'
      @sheets = sheet_scope
      render 'scope', layout: false
      return
    end

    @sheets = sheet_scope.page(params[:page]).per( current_user.pagination_count('sheets') )

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
    params[:current_design_page] = 1

    @sheet = current_user.sheets.new(post_params)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sheet }
    end
  end

  # GET /sheets/1/edit
  def edit
    params[:current_design_page] = 1
    @sheet = current_user.all_sheets.find_by_id(params[:id])
    redirect_to sheets_path unless @sheet
  end

  def remove_file
    @sheet = current_user.all_sheets.find_by_id(params[:id])
    @sheet_variable = @sheet.sheet_variables.find_by_variable_id(params[:variable_id]) if @sheet
    @variable = @sheet_variable.variable if @sheet_variable
    if @sheet_variable and @variable
      @sheet_variable.remove_response_file!
    else
      render nothing: true
    end
  end

  # POST /sheets
  # POST /sheets.json
  def create
    @sheet = current_user.sheets.new(post_params)

    respond_to do |format|
      if @sheet.save
        update_variables!

        if params[:current_design_page].to_i < @sheet.design.total_pages
          format.html { render 'edit' }
          format.json { head :no_content }
        else
          format.html { redirect_to @sheet, notice: 'Sheet was successfully created.' }
          format.json { render json: @sheet, status: :created, location: @sheet }
        end
      else
        params[:current_design_page] = 1
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

          if params[:current_design_page].to_i <= @sheet.design.total_pages
            format.html { render 'edit' }
            format.json { head :no_content }
          else
            format.html { redirect_to @sheet, notice: 'Sheet was successfully updated.' }
            format.json { head :no_content }
          end
        else
          params[:current_design_page] = 1
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

  def generate_csv(sheet_scope, raw_data)
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
            raw_data ? variable.response_raw(sheet) : (variable.variable_type == 'checkbox' ? variable.response_name(sheet).join(',') : variable.response_name(sheet))
          else
            ''
          end
        end
        csv << row
      end
    end
    send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
                          disposition: "attachment; filename=\"Sheets #{Time.now.strftime("%Y.%m.%d %Ih%M %p")} #{raw_data ? 'raw' : 'labeled' }.csv\""
  end

  def post_params
    params[:sheet] ||= {}

    params[:sheet][:project_id] = nil unless current_user.all_viewable_projects.pluck(:id).include?(params[:sheet][:project_id].to_i)

    unless params[:sheet][:project_id].blank? or params[:subject_code].blank? or params[:site_id].blank?
      subject = Subject.find_or_create_by_project_id_and_subject_code(params[:sheet][:project_id], params[:subject_code], { user_id: current_user.id, site_id: params[:site_id], acrostic: params[:subject_acrostic].to_s })
      if subject.site and params[:subject_code] <= subject.site.code_maximum.to_s and params[:subject_code].size <= subject.site.code_maximum.to_s.size and params[:subject_code] >= subject.site.code_minimum.to_s and params[:subject_code].size >= subject.site.code_minimum.to_s.size
        subject.update_attributes validated: true
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
  #     sv.update_attributes response: response
  #   end
  # end

  def update_variables!
    (params[:variables] || {}).each_pair do |variable_id, response|
      sv = @sheet.sheet_variables.find_or_create_by_variable_id(variable_id, { user_id: current_user.id } )
      respone = {} if sv.variable.variable_type == 'file' and response.blank?
      response = [] if sv.variable.variable_type == 'checkbox' and response.blank?
      response = (sv.variable.variable_type == 'date') ? parse_date(response, response) : response
      response = (sv.variable.variable_type == 'time') ? parse_time(response) : response # Currently things that aren't parsed are stored as blank.
      if sv.variable.variable_type == 'file'
        sv.update_attributes response
      else
        sv.update_attributes response: response
      end
    end
  end

end
