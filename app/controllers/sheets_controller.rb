class SheetsController < ApplicationController
  before_action :authenticate_user!, except: [ :survey, :submit_survey, :submit_public_survey ]
  before_action :set_viewable_project, only: [ :index, :show, :print ]
  before_action :set_editable_project, only: [ :edit, :project_selection, :audits, :new, :remove_file, :create, :update, :destroy ]
  before_action :redirect_without_project, only: [ :index, :show, :print, :edit, :project_selection, :audits, :new, :remove_file, :create, :update, :destroy ]
  before_action :set_viewable_sheet, only: [ :show, :print ]
  before_action :set_editable_sheet, only: [ :edit, :audits, :remove_file, :update, :destroy ]
  before_action :redirect_without_sheet, only: [ :show, :print, :edit, :audits, :remove_file, :update, :destroy ]

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
    if @project.designs.size == 1
      params[:sheet] ||= {}
      params[:sheet][:design_id] ||= @project.designs.first.id
    end

    @sheet = current_user.sheets.new(sheet_params)
  end

  # GET /sheets/1/edit
  def edit
  end

  def survey
    @project = Project.current.find_by_id(params[:project_id])
    @sheet = @project.sheets.where(id: params[:id]).find_by_authentication_token(params[:sheet_authentication_token]) if @project and not params[:sheet_authentication_token].blank?
    respond_to do |format|
      if @project and @sheet
        @design = @sheet.design
        format.html { render layout: 'minimal_layout' } # survey.html.erb
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
      UserMailer.survey_completed(@sheet).deliver if Rails.env.production?
      redirect_to about_survey_path(project_id: @project.id, sheet_id: @sheet.id, sheet_authentication_token: @sheet.authentication_token)
    else
      redirect_to new_user_session_path, alert: 'Survey has already been submitted.'
    end
  end

  def submit_public_survey
    @project = Project.current.find_by_id(params[:project_id])
    @design = @project.designs.find_by_id(params[:id]) if @project # :id is the design ID!
    if @project and @design and @design.publicly_available?
      @subject = @project.create_valid_subject(params[:email])
      @sheet = @project.sheets.create( design_id: @design.id, subject_id: @subject.id, user_id: @project.user_id, last_user_id: @project.user_id, authentication_token: Digest::SHA1.hexdigest(Time.now.usec.to_s) )
      update_variables!
      UserMailer.survey_completed(@sheet).deliver if Rails.env.production?
      UserMailer.survey_user_link(@sheet).deliver if Rails.env.production? and not @subject.email.blank?
      redirect_to about_survey_path(project_id: @project.id, sheet_id: @sheet.id, sheet_authentication_token: @sheet.authentication_token)
    else
      redirect_to about_survey_path, alert: 'This survey no longer exists.'
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
        url = (params[:continue].to_s == '1' ? new_project_sheet_path(@sheet.project, sheet: { design_id: @sheet.design_id }) : [@sheet.project, @sheet])

        format.html { redirect_to url, notice: 'Sheet was successfully created.' }
        format.json { render action: 'show', status: :created, location: @sheet }
      else
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
        url = (params[:continue].to_s == '1' ? new_project_sheet_path(@sheet.project, sheet: { design_id: @sheet.design_id }) : [@sheet.project, @sheet])

        format.html { redirect_to url, notice: 'Sheet was successfully updated.' }
        format.json { head :no_content }
      else
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

      params[:sheet][:project_id] = @project.id

      unless params[:subject_code].blank? or params[:site_id].blank?
        subject = @project.subjects.where( subject_code: params[:subject_code] ).first_or_create( user_id: current_user.id, site_id: params[:site_id], acrostic: params[:subject_acrostic].to_s )
        subject.update( status: 'valid' ) if subject.site and subject.site.valid_subject_code?(params[:subject_code]) and subject.status != 'test'
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
        case sv.variable.variable_type when 'grid'
          sv.update_grid_responses!(response, creator)
        when 'checkbox'
          response = [] if response.blank?
          sv.update_responses!(response, creator, sv.sheet) # Response should be an array
        else
          sv.update_attributes sv.format_response(sv.variable.variable_type, response)
        end
      end
      @sheet.update_column :response_count, @sheet.non_blank_design_variable_responses
      @sheet.update_column :total_response_count, @sheet.total_design_variables
    end

end
