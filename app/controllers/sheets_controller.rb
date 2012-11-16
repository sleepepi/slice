class SheetsController < ApplicationController
  before_filter :authenticate_user!, except: [ :survey, :submit_survey ]

  def project_selection
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    @subject = @project.subjects.find_by_subject_code(params[:subject_code]) if @project
    @sheet = current_user.all_sheets.find_by_id(params[:sheet_id]) if @project
    if @sheet
      @sheet_id = @sheet.id
      @design = @sheet.design
    else
      @sheet_id = nil
      @design = @project.designs.find_by_id(params[:sheet][:design_id]) if @project and params[:sheet]
    end

    @study_date = parse_date(params[:sheet] ? params[:sheet][:study_date] : '')

    @site = @project.sites.find_by_id(@project.site_id_with_prefix(params[:subject_code])) if @project

    @subject_code_valid = (@site and @site.valid_subject_code?(params[:subject_code]) ? true : false)

    @valid_study_date = if @study_date.blank?
      false
    elsif @project and @subject and @design and not @sheet_id.blank?
      (@project.sheets.where("sheets.id != ?", @sheet_id).where(subject_id: @subject.id, design_id: @design.id, study_date: @study_date)).count == 0
    elsif @project and @subject and @design
      (@project.sheets.where(subject_id: @subject.id, design_id: @design.id, study_date: @study_date)).count == 0
    else
      true
    end

    @disable_selection = (params[:select] != '1')
  end

  def send_email
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    @sheet = current_user.all_sheets.find_by_id(params[:id])

    if @project and @sheet
      html = render_to_string action: 'print', id: params[:id], layout: false

      pdf_attachment = nil

      # if params[:pdf_attachment] == '1'
      #   pdf_attachment = begin
      #     kit = PDFKit.new(html)
      #     stylesheet_file = "#{Rails.root}/public/assets/application.css"
      #     kit.stylesheets << "#{Rails.root}/public/assets/application.css" if File.exists?(stylesheet_file)
      #     filename = "#{@sheet.subject.subject_code.strip.gsub(/[^\w]/, '-')}_#{@sheet.study_date.strftime("%Y-%m-%d")}_#{@sheet.name.strip.gsub(/[^\w]/, '-')}.pdf"
      #     kit.to_file("#{Rails.root}/tmp/#{filename}")
      #   rescue
      #     nil
      #   end
      # end

      if params[:pdf_attachment] == '1'
        file_pdf_location = @sheet.latex_file_location(current_user)
        pdf_attachment = File.new(file_pdf_location) if File.exists?(file_pdf_location)
      end

      @sheet_email = @sheet.sheet_emails.create(email_body: params[:body], email_cc: params[:cc], email_pdf_file: pdf_attachment, email_subject: params[:subject], email_to: params[:to], user_id: current_user.id)

      @sheet_email.email_receipt

      respond_to do |format|
        format.html { redirect_to [@project, @sheet], notice: 'Sheet receipt email was successfully sent.' }
        format.json { render json: @sheet }
      end
    elsif @project
      respond_to do |format|
        format.html { redirect_to project_sheets_path(@project), alert: 'You do not have sufficient privileges to send a sheet receipt email.' }
        format.json { render head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'You do not have sufficient privileges to access this project.' }
        format.json { render head :no_content }
      end
    end
  end

  # GET /sheets
  # GET /sheets.json
  def index
    @project = current_user.all_viewable_and_site_projects.find_by_id(params[:project_id])

    if @project
      current_user.pagination_set!('sheets', params[:sheets_per_page].to_i) if params[:sheets_per_page].to_i > 0
      sheet_scope = current_user.all_viewable_sheets

      @filter = ['all', 'first', 'last'].include?(params[:filter]) ? params[:filter] : 'all'
      sheet_scope = sheet_scope.last_entry if @filter == 'last'
      sheet_scope = sheet_scope.first_entry if @filter == 'first'

      @statuses = params[:statuses] || ['valid', 'pending', 'test']
      sheet_scope = sheet_scope.with_subject_status(@statuses)

      @sheet_after = parse_date(params[:sheet_after])
      @sheet_before = parse_date(params[:sheet_before])

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

      @raw_data = (params[:format] == 'raw_csv')

      @sheet_count = sheet_scope.count

      if params[:format] == 'labeled_csv'
        if @sheet_count == 0
          redirect_to project_sheets_path(@project), alert: 'No data was exported since no sheets matched the specified filters.'
          return
        end
        generate_csv(sheet_scope, false)
        return
      elsif params[:format] == 'raw_csv'
        if @sheet_count == 0
          redirect_to project_sheets_path(@project), alert: 'No data was exported since no sheets matched the specified filters.'
          return
        end
        generate_csv(sheet_scope, true)
        return
      end

      if params[:format] == 'scope'
        @sheets = sheet_scope
        # render 'scope', layout: false

        if @sheets
          file_pdf_location = Sheet.latex_file_location(@sheets, current_user)

          if File.exists?(file_pdf_location)
            File.open(file_pdf_location, 'r') do |file|
              send_file file, filename: "sheets_#{Time.now.strftime("%Y%m%d_%H%M%S")}.pdf", type: "application/pdf", disposition: "inline"
            end
          else
            render text: "PDF did not render in time. Please refresh the page."
          end
        else
          render nothing: true
        end



        return
      end

      @sheets = sheet_scope.page(params[:page]).per( current_user.pagination_count('sheets') )
      @sheet_scope = sheet_scope
    end

    respond_to do |format|
      if @project
        format.html # index.html.erb
        format.js
        format.json { render json: @sheets }
        format.xls { generate_xls(sheet_scope) }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # This is the latex view
  def print
    @sheet = current_user.all_viewable_sheets.find_by_id(params[:id])
    if @sheet
      file_pdf_location = @sheet.latex_file_location(current_user)

      if File.exists?(file_pdf_location)
        File.open(file_pdf_location, 'r') do |file|
          send_file file, filename: "sheet_#{@sheet.id}.pdf", type: "application/pdf", disposition: "inline"
        end
      else
        render text: "PDF did not render in time. Please refresh the page."
      end
    else
      render nothing: true
    end
  end

  # Old print view
  # def print
  #   @sheet = current_user.all_viewable_sheets.find_by_id(params[:id])
  #   if @sheet
  #     render layout: false
  #   else
  #     render nothing: true
  #   end
  # end

  # GET /sheets/1
  # GET /sheets/1.json
  def show
    @project = current_user.all_viewable_and_site_projects.find_by_id(params[:project_id])
    @sheet = current_user.all_viewable_sheets.find_by_id(params[:id])

    respond_to do |format|
      if @project and @sheet
        @sheet.audit_show!(current_user)
        format.html # show.html.erb
        format.json { render json: @sheet }
      elsif @project
        format.html { redirect_to project_sheets_path(@project), alert: 'You do not have sufficient privileges to view this sheet.' }
        format.json { render head :no_content }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  def audits
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    @sheet = current_user.all_viewable_sheets.find_by_id(params[:id])

    respond_to do |format|
      if @project and @sheet
        format.html # audits.html.erb
        format.json { render json: @sheet }
      elsif @project
        format.html { redirect_to project_sheets_path(@project), alert: 'You do not have sufficient privileges to view sheet audits.' }
        format.json { render head :no_content }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /sheets/new
  # GET /sheets/new.json
  def new
    params[:current_design_page] = 1

    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])

    if @project and @project.designs.size == 1
      params[:sheet] ||= {}
      params[:sheet][:design_id] ||= @project.designs.first.id
    end

    @sheet = current_user.sheets.new(post_params)

    respond_to do |format|
      if @project and @sheet
        format.html # new.html.erb
        format.json { render json: @sheet }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /sheets/1/edit
  def edit
    params[:current_design_page] = 1
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    @sheet = current_user.all_sheets.find_by_id(params[:id])
    redirect_to sheets_path unless @project and @sheet
  end

  def survey
    @project = Project.current.find_by_id(params[:project_id])
    @sheet = @project.sheets.where(id: params[:id]).find_by_authentication_token(params[:sheet_authentication_token]) if @project and not params[:sheet_authentication_token].blank?
    if @project and @sheet
      # survey.html.erb
    else
      redirect_to new_user_session_path, alert: 'Survey has already been submitted.'
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
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])

    @sheet = current_user.all_sheets.find_by_id(params[:id])
    @sheet_variable = @sheet.sheet_variables.find_by_id(params[:sheet_variable_id]) if @sheet

    @object = if params[:position].blank? or params[:variable_id].blank?
      @sheet_variable if @sheet and @sheet_variable # SheetVariable
    else
      @sheet_variable.grids.find_by_variable_id_and_position(params[:variable_id], params[:position].to_i) if @sheet_variable  # Grid
    end

    @variable = @sheet_variable.variable if @object
    if @project and @object and @variable
      @object.remove_response_file!
    else
      render nothing: true
    end
  end

  # POST /sheets
  # POST /sheets.json
  def create
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    @sheet = current_user.sheets.new(post_params)

    respond_to do |format|
      if @project
        if @sheet.save
          update_variables!

          if params[:current_design_page].to_i <= @sheet.design.total_pages
            format.html { render action: 'edit' }
            format.json { head :no_content }
          else
            if params[:continue].to_s == '1'
              format.html { redirect_to new_project_sheet_path(@sheet.project, sheet: { design_id: @sheet.design_id }), notice: 'Sheet was successfully created.' }
            else
              format.html { redirect_to [@sheet.project, @sheet], notice: 'Sheet was successfully created.' }
            end
            format.json { render json: @sheet, status: :created, location: @sheet }
          end
        else
          params[:current_design_page] = 1
          format.html { render action: "new" }
          format.json { render json: @sheet.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # PUT /sheets/1
  # PUT /sheets/1.json
  def update
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    @sheet = current_user.all_sheets.find_by_id(params[:id])

    respond_to do |format|
      if @project and @sheet
        if @sheet.update_attributes(post_params)
          update_variables!

          if params[:current_design_page].to_i <= @sheet.design.total_pages
            format.html { render action: 'edit' }
            format.json { head :no_content }
          else
            if params[:continue].to_s == '1'
              format.html { redirect_to new_project_sheet_path(@sheet.project, sheet: { design_id: @sheet.design_id }), notice: 'Sheet was successfully updated.' }
            else
              format.html { redirect_to [@project, @sheet], notice: 'Sheet was successfully updated.' }
            end
            format.json { head :no_content }
          end
        else
          params[:current_design_page] = 1
          format.html { render action: "edit" }
          format.json { render json: @sheet.errors, status: :unprocessable_entity }
        end
      elsif @project
        format.html { redirect_to project_sheets_path(@project), alert: 'You do not have sufficient privileges to update this sheet.' }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /sheets/1
  # DELETE /sheets/1.json
  def destroy
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    @sheet = current_user.all_sheets.find_by_id(params[:id])
    @sheet.destroy if @project and @sheet

    respond_to do |format|
      if @project
        format.html { redirect_to project_sheets_path(@project) }
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

  def generate_csv(sheet_scope, raw_data)
    @csv_string = CSV.generate do |csv|
      variable_names = sheet_scope.collect(&:variables).flatten.uniq.collect{|v| v.name}.uniq
      csv << ["Name", "Description", "Sheet Date", "Project", "Site", "Subject", "Acrostic", "Creator"] + variable_names
      sheet_scope.each do |sheet|
        row = [sheet.name,
                sheet.description,
                sheet.study_date.blank? ? '' : sheet.study_date.strftime("%m-%d-%Y"),
                sheet.project.name,
                sheet.subject.site.name,
                sheet.subject.name,
                sheet.project.acrostic_enabled? ? sheet.subject.acrostic : nil,
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

  def generate_xls(sheet_scope)

    export = current_user.exports.create(name: "#{current_user.last_name}_#{Date.today.strftime("%Y%m%d")}", project_id: @project.id, export_type: 'sheets')

    sheet_ids = sheet_scope.pluck(:id)

    systemu "#{RAKE_PATH} sheet_export EXPORT_ID=#{export.id} SHEET_IDS='#{sheet_ids.join(',')}' &"

    redirect_to project_sheets_path(@project), notice: 'You will be emailed when the export is ready for download.'

    # Spreadsheet.client_encoding = 'UTF-8'
    # book = Spreadsheet::Workbook.new

    # [false, true].each do |raw_data|
    #   worksheet = book.create_worksheet name: "Sheets - #{raw_data ? 'RAW' : 'Labeled'}"
    #   variable_names = sheet_scope.collect(&:variables).flatten.uniq.collect{|v| [v.name, 'String']}.uniq

    #   current_row = 0

    #   worksheet.row(current_row).replace ["Name", "Description", "Sheet Date", "Project", "Site", "Subject", "Acrostic", "Creator"] + variable_names.collect{|v| v[0]}

    #   sheet_scope.each do |s|
    #     current_row += 1
    #     worksheet.row(current_row).push s.name, s.description, (s.study_date.blank? ? '' : s.study_date.strftime("%m-%d-%Y")), s.project.name, s.subject.site.name, s.subject.name, (s.project.acrostic_enabled? ? s.subject.acrostic : nil), s.user.name

    #     variable_names.each do |name, type|
    #       value = if variable = s.variables.find_by_name(name)
    #         raw_data ? variable.response_raw(s) : (variable.variable_type == 'checkbox' ? variable.response_name(s).join(',') : variable.response_name(s))
    #       else
    #         ''
    #       end
    #       worksheet.row(current_row).push value
    #     end
    #   end


    #   current_row = 0

    #   worksheetgrid = book.create_worksheet name: "Grids - #{raw_data ? 'RAW' : 'Labeled'}"

    #   variable_ids = SheetVariable.where(sheet_id: sheet_scope.pluck(:id)).collect(&:variable_id)
    #   grid_group_variables = Variable.current.where(variable_type: 'grid', id: variable_ids)
    #   @grids = sheet_scope.collect(&:sheet_variables).flatten.collect(&:grids).flatten.compact.uniq

    #   worksheetgrid.row(current_row).replace ["", "", "", "", "", "", "", ""]

    #   grid_group_variables.each do |variable|
    #     variable.grid_variables.each do |grid_variable_hash|
    #       grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
    #       worksheetgrid.row(current_row).push variable.name if grid_variable
    #     end
    #   end

    #   current_row += 1
    #   worksheetgrid.row(current_row).replace ["Name", "Description", "Sheet Date", "Project", "Site", "Subject", "Acrostic", "Creator"]

    #   grid_group_variables.each do |variable|
    #     variable.grid_variables.each do |grid_variable_hash|
    #       grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
    #       worksheetgrid.row(current_row).push grid_variable.name if grid_variable
    #     end
    #   end

    #   sheet_scope.each do |s|
    #     (0..s.max_grids_position).each do |position|
    #       current_row += 1
    #       worksheetgrid.row(current_row).push s.name, s.description, (s.study_date.blank? ? '' : s.study_date.strftime("%m-%d-%Y")), s.project.name, s.subject.site.name, s.subject.name, (s.project.acrostic_enabled? ? s.subject.acrostic : nil), s.user.name

    #       grid_group_variables.each do |variable|
    #         variable.grid_variables.each do |grid_variable_hash|
    #           sheet_variable = s.sheet_variables.find_by_variable_id(variable.id)
    #           result_hash = (sheet_variable ? sheet_variable.response_hash(position, grid_variable_hash[:variable_id]) : {})
    #           cell = if raw_data
    #             result_hash.kind_of?(Array) ? result_hash.collect{|h| h[:value]}.join(',') : result_hash[:value]
    #           else
    #             result_hash.kind_of?(Array) ? result_hash.collect{|h| "#{h[:value]}: #{h[:name]}"}.join(', ') : result_hash[:name]
    #           end
    #           worksheetgrid.row(current_row).push cell
    #         end
    #       end
    #     end
    #   end
    # end

    # buffer = StringIO.new
    # book.write(buffer)
    # buffer.rewind


    # send_data buffer.read, type: 'application/vnd.ms-excel; charset=iso-8859-1; header=present',
    #                        disposition: "attachment; filename=\"Sheets #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.xls\""
  end

  def post_params
    params[:sheet] ||= {}

    if current_user.all_viewable_projects.pluck(:id).include?(params[:project_id].to_i)
      params[:sheet][:project_id] = params[:project_id]
    else
      params[:sheet][:project_id] = nil
    end

    unless params[:sheet][:project_id].blank? or params[:subject_code].blank? or params[:site_id].blank?
      subject = Subject.find_or_create_by_project_id_and_subject_code(params[:sheet][:project_id], params[:subject_code], { user_id: current_user.id, site_id: params[:site_id], acrostic: params[:subject_acrostic].to_s })
      if subject.site and subject.site.valid_subject_code?(params[:subject_code])
        subject.update_attributes status: 'valid'
      end
    end

    subject.update_attributes acrostic: params[:subject_acrostic].to_s if subject

    params[:sheet][:subject_id] = (subject ? subject.id : nil)
    params[:sheet][:last_user_id] = current_user.id

    [:study_date].each do |date|
      params[:sheet][date] = parse_date(params[:sheet][date])
    end

    params[:sheet].slice(
      :design_id, :study_date, :project_id, :subject_id, :variable_ids, :last_user_id
    )
  end

  def update_variables!
    (params[:variables] || {}).each_pair do |variable_id, response|
      creator = (current_user ? current_user : @sheet.user)

      sv = @sheet.sheet_variables.find_or_create_by_variable_id(variable_id, { user_id: creator.id } )
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
  end

end
