class SheetsController < ApplicationController
  before_action :authenticate_user!, except: [ :survey, :submit_survey ]
  before_action :set_viewable_project, only: [ :index, :show, :print ]
  before_action :set_editable_project, only: [ :edit, :project_selection, :send_email, :audits, :new, :remove_file, :create, :update, :destroy ]
  before_action :redirect_without_project, only: [ :index, :show, :print, :edit, :project_selection, :send_email, :audits, :new, :remove_file, :create, :update, :destroy ]
  before_action :set_viewable_sheet, only: [ :show, :print ]
  before_action :set_editable_sheet, only: [ :edit, :send_email, :audits, :remove_file, :update, :destroy ]
  before_action :redirect_without_sheet, only: [ :show, :print, :edit, :send_email, :audits, :remove_file, :update, :destroy ]

  def project_selection
    @subject = @project.subjects.find_by_subject_code(params[:subject_code])
    @sheet = current_user.all_sheets.find_by_id(params[:sheet_id])
    if @sheet
      @sheet_id = @sheet.id
      @design = @sheet.design
    else
      @sheet_id = nil
      @design = @project.designs.find_by_id(params[:sheet][:design_id]) if params[:sheet]
    end

    @site = @project.sites.find_by_id(@project.site_id_with_prefix(params[:subject_code]))

    @subject_code_valid = (@site and @site.valid_subject_code?(params[:subject_code]) ? true : false)

    @disable_selection = (params[:select] != '1')
  end

  def send_email
    pdf_attachment = nil

    if params[:pdf_attachment] == '1'
      file_pdf_location = Sheet.latex_file_location([@sheet], current_user)
      pdf_attachment = File.new(file_pdf_location) if File.exists?(file_pdf_location)
    end

    @sheet_email = @sheet.sheet_emails.create(email_body: params[:body], email_cc: params[:cc], email_pdf_file: pdf_attachment, email_subject: params[:subject], email_to: params[:to], user_id: current_user.id)

    @sheet_email.email_receipt

    respond_to do |format|
      format.html { redirect_to [@project, @sheet], notice: 'Sheet receipt email was successfully sent.' }
      format.json { render json: @sheet }
    end
  end

  # GET /sheets
  # GET /sheets.json
  def index
    current_user.pagination_set!('sheets', params[:sheets_per_page].to_i) if params[:sheets_per_page].to_i > 0
    sheet_scope = current_user.all_viewable_sheets.search(params[:search])

    @filter = ['all', 'first', 'last'].include?(params[:filter]) ? params[:filter] : 'all'
    sheet_scope = sheet_scope.last_entry if @filter == 'last'
    sheet_scope = sheet_scope.first_entry if @filter == 'first'

    @statuses = params[:statuses] || ['valid', 'pending', 'test']
    sheet_scope = sheet_scope.with_subject_status(@statuses)

    @sheet_after = parse_date(params[:sheet_after])
    @sheet_before = parse_date(params[:sheet_before])

    sheet_scope = Sheet.filter_sheet_scope(sheet_scope, params[:f])

    @variable = current_user.all_viewable_variables.find_by_id(params[:stratum_id])
    @column_variable = current_user.all_viewable_variables.find_by_id(params[:column_stratum_id])

    sheet_scope = sheet_scope.sheet_before_variable_with_blank(@column_variable, @sheet_before) unless @sheet_before.blank?
    sheet_scope = sheet_scope.sheet_after_variable_with_blank(@column_variable, @sheet_after) unless @sheet_after.blank?


    if params[:row_include] == 'all'
      # No filter required
    elsif @variable and params[:row_include] == 'known'
      # Filter only known (non-missing) values for @variable
      sheet_scope = sheet_scope.with_any_variable_response_not_missing_code(@variable)
    elsif @variable and params[:row_include] == 'missing' # Missing or Known
      sheet_scope = sheet_scope.with_any_variable_response(@variable)
    elsif @variable and params[:row_include] == 'unknown'
      # Filter to only @variable where it's unknown
      sheet_scope = sheet_scope.without_variable_response(@variable)
    end

    if params[:column_include] == 'all'
      # No filter required
    elsif @column_variable and params[:column_include] == 'known'
      # Filter only known (non-missing) values for @column_variable
      sheet_scope = sheet_scope.with_any_variable_response_not_missing_code(@column_variable)
    elsif @column_variable and params[:column_include] == 'missing'
      sheet_scope = sheet_scope.with_any_variable_response(@column_variable)
    elsif @column_variable and params[:column_include] == 'unknown'
      # Filter to only @column_variable where it's unknown
      sheet_scope = sheet_scope.without_variable_response(@column_variable)
    end

    if params[:stratum_id].blank? and not params[:stratum_value].blank?
      params[:site_id] = params[:stratum_value]
      params[:stratum_value] = nil
    end

    sheet_scope = sheet_scope.with_stratum(params[:stratum_id], params[:stratum_value]) unless params[:stratum_value].blank?
    sheet_scope = sheet_scope.with_stratum(params[:column_stratum_id], params[:column_stratum_value]) unless (@column_variable and @column_variable.variable_type == 'date') or params[:column_stratum_id].blank? or params[:column_stratum_value].blank?

    ['design', 'project', 'site', 'user'].each do |filter|
      sheet_scope = sheet_scope.send("with_#{filter}", params["#{filter}_id".to_sym]) unless params["#{filter}_id".to_sym].blank?
    end

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
    when 'sheets.user_name'
      sheet_scope = sheet_scope.order_by_user_name
    when 'sheets.user_name DESC'
      sheet_scope = sheet_scope.order_by_user_name_desc
    else
      @order = scrub_order(Sheet, params[:order], 'sheets.created_at DESC')
      sheet_scope = sheet_scope.order(@order)
    end

    @raw_data = (params[:format] == 'raw_csv')

    generate_export(sheet_scope, (params[:csv_labeled].to_s == '1'), (params[:csv_raw].to_s == '1'), (params[:pdf].to_s == '1'), (params[:files].to_s == '1'), (params[:data_dictionary].to_s == '1'), (params[:sas].to_s == '1')) if params[:export].to_s == '1'

    @sheets = sheet_scope.page(params[:page]).per( current_user.pagination_count('sheets') )
    @sheet_scope = sheet_scope
  end

  # This is the latex view
  def print
    file_pdf_location = Sheet.latex_file_location([@sheet], current_user)

    if File.exists?(file_pdf_location)
      send_file file_pdf_location, filename: "sheet_#{@sheet.id}.pdf", type: "application/pdf", disposition: "inline"
    else
      render text: "PDF did not render in time. Please refresh the page."
    end
  end

  # GET /sheets/1
  # GET /sheets/1.json
  def show
    @sheet.audit_show!(current_user)
  end

  def audits

  end

  # GET /sheets/new
  def new
    params[:current_design_page] = 1

    if @project.designs.size == 1
      params[:sheet] ||= {}
      params[:sheet][:design_id] ||= @project.designs.first.id
    end

    @sheet = current_user.sheets.new(sheet_params)
  end

  # GET /sheets/1/edit
  def edit
    params[:current_design_page] = 1
  end

  def survey
    @project = Project.current.find_by_id(params[:project_id])
    @sheet = @project.sheets.where(id: params[:id]).find_by_authentication_token(params[:sheet_authentication_token]) if @project and not params[:sheet_authentication_token].blank?
    respond_to do |format|
      if @project and @sheet
        @design = @sheet.design
        format.html # survey.html.erb
        format.js   # survey.js.erb
      else
        format.html { redirect_to new_user_session_path, alert: 'Survey has already been submitted.' }
        format.js { render nothing: true }
      end
    end
  end

  def submit_survey
    @project = Project.current.find_by_id(params[:project_id])
    @sheet = @project.sheets.where(id: params[:id]).find_by_authentication_token(params[:sheet_authentication_token]) if @project and not params[:sheet_authentication_token].blank?
    if @project and @sheet
      update_variables!

      if params[:current_design_page].to_i <= @sheet.design.total_pages
        render action: 'survey'
      else
        UserMailer.survey_completed(@sheet).deliver if Rails.env.production?
        redirect_to about_path, notice: 'Survey submitted successfully.'
      end

    else
      redirect_to new_user_session_path, alert: 'Survey has already been submitted.'
    end
  end

  def remove_file
    @sheet_variable = @sheet.sheet_variables.find_by_id(params[:sheet_variable_id])

    @object = if params[:position].blank? or params[:variable_id].blank?
      @sheet_variable
    else
      @sheet_variable.grids.find_by_variable_id_and_position(params[:variable_id], params[:position].to_i) if @sheet_variable  # Grid
    end

    @variable = @sheet_variable.variable if @object

    if @object and @variable
      @object.remove_response_file!
    else
      render nothing: true
    end
  end

  # POST /sheets
  # POST /sheets.json
  def create
    @sheet = current_user.sheets.new(sheet_params)

    respond_to do |format|
      if @sheet.save
        update_variables!

        if params[:current_design_page].to_i <= @sheet.design.total_pages
          format.html { render action: 'edit' }
        else
          if params[:continue].to_s == '1'
            format.html { redirect_to new_project_sheet_path(@sheet.project, sheet: { design_id: @sheet.design_id }), notice: 'Sheet was successfully created.' }
          else
            format.html { redirect_to [@sheet.project, @sheet], notice: 'Sheet was successfully created.' }
          end
        end
        format.json { render action: 'show', status: :created, location: @sheet }
      else
        params[:current_design_page] = 1
        format.html { render action: 'new' }
        format.json { render json: @sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sheets/1
  # PUT /sheets/1.json
  def update
    respond_to do |format|
      if @sheet.update(sheet_params)
        update_variables!

        if params[:current_design_page].to_i <= @sheet.design.total_pages
          format.html { render action: 'edit' }
        else
          if params[:continue].to_s == '1'
            format.html { redirect_to new_project_sheet_path(@sheet.project, sheet: { design_id: @sheet.design_id }), notice: 'Sheet was successfully updated.' }
          else
            format.html { redirect_to [@project, @sheet], notice: 'Sheet was successfully updated.' }
          end
        end
        format.json { head :no_content }
      else
        params[:current_design_page] = 1
        format.html { render action: 'edit' }
        format.json { render json: @sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sheets/1
  # DELETE /sheets/1.json
  def destroy
    @sheet.destroy

    respond_to do |format|
      format.html { redirect_to project_sheets_path(@project) }
      format.js
      format.json { head :no_content }
    end
  end

  private

    def set_viewable_sheet
      @sheet = current_user.all_viewable_sheets.find_by_id(params[:id])
    end

    def set_editable_sheet
      @sheet = @project.sheets.find_by_id(params[:id])
    end

    def redirect_without_sheet
      empty_response_or_root_path(project_sheets_path(@project)) unless @sheet
    end

    def sheet_params
      params[:sheet] ||= {}

      if current_user.all_viewable_projects.pluck(:id).include?(params[:project_id].to_i)
        params[:sheet][:project_id] = params[:project_id]
      else
        params[:sheet][:project_id] = nil
      end

      unless params[:sheet][:project_id].blank? or params[:subject_code].blank? or params[:site_id].blank?
        subject = Subject.where( project_id: params[:sheet][:project_id], subject_code: params[:subject_code] ).first_or_create( user_id: current_user.id, site_id: params[:site_id], acrostic: params[:subject_acrostic].to_s )
        if subject.site and subject.site.valid_subject_code?(params[:subject_code]) and subject.status != 'test'
          subject.update( status: 'valid' )
        end
      end

      subject.update( acrostic: params[:subject_acrostic].to_s ) if subject

      params[:sheet][:subject_id] = (subject ? subject.id : nil)
      params[:sheet][:last_user_id] = current_user.id
      params[:sheet][:last_edited_at] = Time.now

      params.require(:sheet).permit(
        :design_id, :project_id, :subject_id, :variable_ids, :last_user_id, :last_edited_at
      )
    end

    def generate_export(sheet_scope, csv_labeled, csv_raw, pdf, files, data_dictionary, sas)
      export = current_user.exports.create(
                  name: "#{current_user.last_name}_#{Date.today.strftime("%Y%m%d")}",
                  project_id: @project.id,
                  include_csv_labeled: csv_labeled,
                  include_csv_raw: csv_raw,
                  include_pdf: pdf,
                  include_files: files,
                  include_data_dictionary: data_dictionary,
                  include_sas: sas,
                  sheet_ids_count: sheet_scope.count )

      rake_task = "#{RAKE_PATH} sheet_export EXPORT_ID=#{export.id} SHEET_IDS='#{sheet_scope.pluck(:id).join(',')}' &"

      systemu rake_task unless Rails.env.test?

      # flash[:notice] = 'You will be emailed when the export is ready for download.'
      render text: "window.location.href = '#{export_path(export)}';"
    end

    def update_variables!
      (params[:variables] || {}).each_pair do |variable_id, response|
        creator = (current_user ? current_user : @sheet.user)

        sv = @sheet.sheet_variables.where( variable_id: variable_id ).first_or_create( user_id: creator.id )
        variable_type = (sv.variable.variable_type == 'scale' ? sv.variable.scale_type : sv.variable.variable_type)
        case variable_type when 'grid'
          sv.update_grid_responses!(response, creator)
        when 'checkbox'
          response = [] if response.blank?
          sv.update_responses!(response, creator) # Response should be an array
        else
          sv.update_attributes sv.format_response(variable_type, response)
        end
        # if sv.variable.variable_type == 'grid'
        #   sv.update_grid_responses!(response)
        # elsif sv.variable.variable_type == 'scale'
        #   sv.update_attributes sv.format_response(sv.variable.scale_type, response)
        # else
        #   sv.update_attributes sv.format_response(sv.variable.variable_type, response)
        # end
      end
      @sheet.update_column :response_count, @sheet.non_blank_design_variable_responses
      @sheet.update_column :total_response_count, @sheet.total_design_variables
    end

end
