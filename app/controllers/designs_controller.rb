class DesignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [ :print, :report_print, :report, :reporter ]
  before_action :set_editable_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy, :copy, :add_section, :add_variable, :variables, :reorder, :batch, :create_batch, :import, :create_import ]
  before_action :redirect_without_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy, :copy, :add_section, :add_variable, :variables, :reorder, :batch, :create_batch, :print, :report_print, :report, :reporter, :import, :create_import ]
  before_action :set_viewable_design, only: [ :print, :report_print, :report, :reporter ]
  before_action :set_editable_design, only: [ :show, :edit, :update, :destroy, :reorder ]
  before_action :redirect_without_design, only: [ :show, :edit, :update, :destroy, :reorder, :print, :report_print, :report, :reporter ]

  # Concerns
  include Buildable

  def import
    @design = current_user.designs.new(project_id: params[:project_id])
    @variables = []
  end

  def create_import
    @design = current_user.designs.new(design_params)
    if params[:variables].blank?
      @variables = @design.load_variables
      if @design.csv_file.blank?
        @design.errors.add(:csv_file, "must be selected")
      # elsif not @design.header_row.include?('subject_code')
      #   @design.errors.add(:csv_file, "must contain subject_code as a header column")
      end
      @design.name = @design.csv_file.path.split('/').last.gsub(/csv|\./, '').humanize if @design.name.blank? and @design.csv_file.path and @design.csv_file.path.split('/').last
      render "import"
    else
      if @design.save
        @design.create_variables!(params[:variables])

        @design.create_sheets!

        redirect_to project_sheets_path(design_id: @design.id), notice: "Successfully imported #{@design.sheets.count} #{@design.sheets.count == 1 ? 'sheet' : 'sheets'}."
      else
        @variables = @design.load_variables
        @design.name = @design.csv_file.path.split('/').last.gsub(/csv|\./, '').humanize.capitalize if @design.name.blank? and @design.csv_file.path and @design.csv_file.path.split('/').last
        render "import"
      end
    end
  end

  def report_print
    setup_report

    orientation = ['portrait', 'landscape'].include?(params[:orientation].to_s) ? params[:orientation].to_s : 'portrait'

    file_pdf_location = @design.latex_report_file_location(current_user, @sheets, @report_title, @report_caption, @variable, @ranges, @percent, @strata, @column_variable, orientation)

    if File.exists?(file_pdf_location)
      File.open(file_pdf_location, 'r') do |file|
        file_name = @report_title.gsub(' vs. ', ' versus ').gsub(/[^\da-zA-Z ]/, '')
        send_file file, filename: "#{file_name} #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.pdf", type: "application/pdf", disposition: "inline"
      end
    else
      render text: "PDF did not render in time. Please refresh the page."
    end
  end

  def reporter
    setup_report_new

    respond_to do |format|
      format.html # report.html.erb
      format.js { render 'reporter' }
    end
  end

  def report
    setup_report

    if params[:format] == 'csv'
      generate_table_csv(@design, @sheets, @ranges, @strata, @variable, @column_variable, @report_title, @report_caption)
      return
    end

    respond_to do |format|
      format.html # report.html.erb
      format.json { render json: @design }
      format.js { render 'report' }
    end
  end

  def copy
    design = current_user.all_viewable_designs.find_by_id(params[:id])
    @design = current_user.designs.new(design.copyable_attributes) if design

    if @design
      render 'new'
    else
      redirect_to project_designs_path
    end
  end

  def selection
    @project = current_user.all_viewable_projects.find_by_id(params[:project_id])
    params[:current_design_page] = (params[:current_design_page].blank? ? 1 : params[:current_design_page].to_i)
    @sheet = current_user.all_sheets.find_by_id(params[:sheet_id])
    @sheet = Sheet.new unless @sheet
    @design = current_user.all_viewable_designs.find_by_id(params[:sheet][:design_id]) unless params[:sheet].blank?
  end

  def add_section
    @design = Design.new(design_params.except(:option_tokens))
    @option = { }
  end

  def add_variable
    @design = Design.new(design_params)
    @option = { variable_id: '' }
    @all_viewable_variables = current_user.all_viewable_variables.where(project_id: @project.id)
    @select_variables = @all_viewable_variables.order(:name).collect{|v| [v.name, v.id]}
  end

  def variables
    @design = Design.new(design_params)
  end

  def reorder
    if params[:rows].blank?
      @design.reorder_sections(params[:sections].to_s.split(','), current_user)
    else
      @design.reorder(params[:rows].to_s.split(','), current_user)
    end
  end

  def batch
    @designs = @project.designs
    @sites = @project.sites
    @emails = []
  end

  def create_batch
    @design = @project.designs.find_by_id(params[:design_id])
    @site = @project.sites.find_by_id(params[:site_id])
    @emails = params[:emails].to_s.split(/[;\r\n]/).collect{|email| email.strip}.select{|email| not email.blank?}.uniq

    if @design and @site and not @emails.blank?
      (sheets_created, sheets_ignored) = @design.batch_sheets!(current_user, @site, @emails)
      flash[:notice] = "#{sheets_created} #{sheets_created == 1 ? 'sheet was' : 'sheets were'} successfully created." if sheets_created > 0
      flash[:alert] = "#{sheets_ignored} #{sheets_ignored == 1 ? 'sheet was' : 'sheets were'} not created because the #{sheets_ignored == 1 ? 'subject exists' : 'subjects exist'} on a different site." if sheets_ignored > 0
      redirect_to project_sheets_path(@project, site_id: @site.id, design_id: @design.id, user_id: current_user.id)
    else
      redirect_to batch_project_designs_path(emails: @emails.join('; '), site_id: @site ? @site.id : nil, design_id: @design ? @design.id : nil ), alert: 'Please select a design, site, and valid emails.'
    end
  end

  # GET /designs
  # GET /designs.json
  def index
    current_user.pagination_set!('designs', params[:designs_per_page].to_i) if params[:designs_per_page].to_i > 0

    design_scope = current_user.all_viewable_designs.search(params[:search])

    @order = params[:order]
    case params[:order] when 'designs.project_name'
      design_scope = design_scope.order_by_project_name
    when 'designs.project_name DESC'
      design_scope = design_scope.order_by_project_name_desc
    when 'designs.user_name'
      design_scope = design_scope.order_by_user_name
    when 'designs.user_name DESC'
      design_scope = design_scope.order_by_user_name_desc
    else
      @order = scrub_order(Design, params[:order], 'designs.name')
      design_scope = design_scope.order(@order)
    end

    design_scope = design_scope.where(id: params[:design_ids]) unless params[:design_ids].blank?

    ['project', 'user'].each do |filter|
      design_scope = design_scope.send("with_#{filter}", params["#{filter}_id".to_sym]) unless params["#{filter}_id".to_sym].blank?
    end

    if params[:format] == 'csv'
      if design_scope.count == 0
        redirect_to project_designs_path(@project), alert: 'No data was exported since no designs matched the specified filters.'
        return
      end
      generate_csv(design_scope)
      return
    end

    @designs = design_scope.page(params[:page]).per( current_user.pagination_count('designs') )

    respond_to do |format|
      format.html
      format.js
      format.json
      format.xls { generate_xls(design_scope) }
    end
  end

  # This is the latex view
  def print
    file_pdf_location = @design.latex_file_location(current_user)

    if File.exists?(file_pdf_location)
      File.open(file_pdf_location, 'r') do |file|
        send_file file, filename: "design_#{@design.id}.pdf", type: "application/pdf", disposition: "inline"
      end
    else
      render text: "PDF did not render in time. Please refresh the page."
    end
  end

  # GET /designs/1
  # GET /designs/1.json
  def show
  end

  # GET /designs/new
  def new
    @design = current_user.designs.new(updater_id: current_user.id, project_id: params[:project_id])
  end

  # GET /designs/1/edit
  def edit
  end

  # POST /designs
  # POST /designs.json
  def create
    @design = current_user.designs.new(design_params)

    respond_to do |format|
      if @design.save
        format.html { redirect_to [@design.project, @design], notice: 'Design was successfully created.' }
        format.json { render action: 'show', status: :created, location: @design }
      else
        format.html { render action: 'new' }
        format.json { render json: @design.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /designs/1
  # PUT /designs/1.json
  def update
    respond_to do |format|
      if @design.update(design_params)
        format.html { redirect_to [@design.project, @design], notice: 'Design was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @design.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /designs/1
  # DELETE /designs/1.json
  def destroy
    @design.destroy

    respond_to do |format|
      format.html { redirect_to project_designs_path }
      format.js
      format.json { head :no_content }
    end
  end

  private

    def set_viewable_design
      @design = current_user.all_viewable_designs.find_by_id(params[:id])
    end

    def set_editable_design
      @design = @project.designs.find_by_id(params[:id])
    end

    def redirect_without_design
      empty_response_or_root_path(project_designs_path(@project)) unless @design
    end

    def design_params
      params[:design] ||= {}

      params[:design][:updater_id] = current_user.id

      if current_user.all_projects.pluck(:id).include?(params[:project_id].to_i)
        params[:design][:project_id] = params[:project_id]
      else
        params[:design][:project_id] = nil
      end

      params.require(:design).permit(
        :name, :description, :project_id, { :option_tokens => [ :variable_id, :branching_logic, :section_name, :section_id, :section_description, :break_before ] }, :email_template, :email_subject_template, :updater_id, :csv_file, :csv_file_cache
      )
    end

    def generate_csv(design_scope)
      @csv_string = CSV.generate do |csv|
        csv << ['Variable Project', 'Design Name', 'Variable Name', 'Variable Display Name', 'Variable Header', 'Variable Description', 'Variable Type', 'Variable Options', 'Variable Branching Logic', 'Hard Min', 'Soft Min', 'Soft Max', 'Hard Max', 'Calculation', 'Prepend', 'Units', 'Append', 'Variable Creator']

        design_scope.each do |design|
          design.options.each do |option|
            if option[:variable_id].blank?
              row = [
                      design.project ? design.project.name : '',
                      design.name,
                      option[:section_id],
                      option[:section_name],
                      nil, # Variable Header
                      option[:section_description], # Variable Description
                      'section',
                      nil, # Variable Options
                      option[:branching_logic],
                      nil, # Hard Min
                      nil, # Soft Min
                      nil, # Soft Max
                      nil, # Hard Max
                      nil, # Calculation
                      nil, # Variable Prepend
                      nil, # Variable Units
                      nil, # Variable Append
                      nil  # Creator
                    ]
              csv << row
            elsif variable = current_user.all_viewable_variables.find_by_id(option[:variable_id])
              row = [
                      variable.project ? variable.project.name : '',
                      design.name,
                      variable.name,
                      variable.display_name,
                      variable.header, # Variable Header
                      variable.description, # Variable Description
                      variable.variable_type,
                      variable.options.blank? ? '' : variable.options, # Variable Options
                      option[:branching_logic],
                      variable.hard_minimum, # Hard Min
                      variable.soft_minimum, # Soft Min
                      variable.soft_maximum, # Soft Max
                      variable.hard_maximum, # Hard Max
                      variable.calculation, # Calculation
                      variable.prepend, # Variable Prepend
                      variable.units, # Variable Units
                      variable.append, # Variable Append
                      variable.user.name # Creator
                    ]
              csv << row
            end
          end
        end
      end
      file_name = (design_scope.size == 1 ? "#{design_scope.first.name.gsub(/[^ a-zA-Z0-9_-]/, '_')} DD" : 'Designs')
      send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
                             disposition: "attachment; filename=\"#{file_name} #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.csv\""
    end

    def generate_table_csv(design, sheets, ranges, strata, variable, column_variable, report_title, report_caption)
      @csv_string = CSV.generate do |csv|
        csv << [report_title]
        csv << [design.name]
        csv << [design.project.name]
        csv << [report_caption]
        csv << []

        header = [(variable ? variable.display_name : 'Site')]
        header += ranges.collect{|hash| hash[:name].blank? ? 'Unknown' : hash[:name]}
        header += ['Total']
        csv << header

        strata.each do |stratum|
          row = []
          link_name = ((stratum[:value].blank? or stratum[:value] == stratum[:name]) ? '' :  "#{stratum[:value]}: ") + stratum[:name]
          row << (stratum[:name].blank? ? 'Unknown' : link_name)
          ranges.each do |hash|
            count = if column_variable and column_variable.has_statistics?
              Sheet.array_calculation(hash[:scope].with_stratum(variable, stratum[:value]), column_variable, hash[:calculation])
            else
              hash[:scope].with_stratum(variable, stratum[:value]).count
            end

            row << count
          end
          row << sheets.with_stratum(variable, stratum[:value]).count
          csv << row
        end

        footer = ['Total']
        footer += ranges.collect{|hash| hash[:count]}
        footer += [sheets.count]
        csv << footer
      end
      file_name = report_title.gsub('vs.', 'versus').gsub(/[^\da-zA-Z ]/, '')
      send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
                             disposition: "attachment; filename=\"#{file_name} #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.csv\""
    end

    def generate_xls(design_scope)
      export = current_user.exports.create(name: "#{current_user.last_name}_#{Date.today.strftime("%Y%m%d")}", project_id: @project.id, include_data_dictionary: true)

      design_ids = design_scope.pluck(:id)

      systemu "#{RAKE_PATH} design_export EXPORT_ID=#{export.id} DESIGN_IDS='#{design_ids.join(',')}' &"

      redirect_to project_designs_path(@project), notice: 'You will be emailed when the export is ready for download.'
    end

    def setup_report
      @sheet_before = parse_date(params[:sheet_before])
      @sheet_after = parse_date(params[:sheet_after])

      @by = ["week", "month", "year"].include?(params[:by]) ? params[:by] : "month" # "month" or "year"
      @percent = ['none', 'row', 'column'].include?(params[:percent]) ? params[:percent] : 'none'
      @filter = ['all', 'first', 'last'].include?(params[:filter]) ? params[:filter] : 'all'
      @statuses = params[:statuses] || ['valid']

      @variable = @design.pure_variables.find_by_id(params[:variable_id])
      @column_variable = @design.pure_variables.find_by_id(params[:column_variable_id])

      sheet_scope = current_user.all_viewable_sheets.with_design(@design.id).with_subject_status(@statuses)

      sheet_scope = sheet_scope.last_entry if @filter == 'last'
      sheet_scope = sheet_scope.first_entry if @filter == 'first'

      sheet_scope = sheet_scope.sheet_after_variable_with_blank(@column_variable, @sheet_after) unless @sheet_after.blank?
      sheet_scope = sheet_scope.sheet_before_variable_with_blank(@column_variable, @sheet_before) unless @sheet_before.blank?

      sheet_scope = sheet_scope.with_any_variable_response_not_missing_code(@variable) if @variable and params[:include_missing] != '1'
      sheet_scope = sheet_scope.with_any_variable_response_not_missing_code(@column_variable) if @column_variable and params[:column_include_missing] != '1'

      # @ranges = [{ name: "2012", start_date: "2012-01-01", end_date: "2012-12-31" }, { name: "2013", start_date: "2013-01-01", end_date: "2013-12-31" }]
      @ranges = []

      if @column_variable and ['dropdown', 'radio', 'string'].include?(@column_variable.variable_type)
        column_strata = @column_variable.options_or_autocomplete(params[:column_include_missing].to_s == '1')
        column_strata = column_strata + [{ name: '', value: nil }] if params[:column_include_missing].to_s == '1'
        column_strata.each do |stratum|
          scope = sheet_scope.with_stratum(@column_variable, stratum[:value])
          @ranges << { name: (((stratum[:value].blank? or stratum[:value] == stratum[:name]) ? '' : stratum[:value] + ": ") + stratum[:name]), tooltip: stratum[:name], start_date: '', end_date: '', scope: scope, count: scope.count, value: stratum[:value], calculation: 'array_count' }
        end
      elsif @column_variable and @column_variable.has_statistics?
        column_strata = [{ name: 'Mean', calculation: 'array_mean' }, { name: 'StdDev', calculation: 'array_standard_deviation', symbol: 'pm' }, { name: 'Median', calculation: 'array_median' }, { name: 'Min', calculation: 'array_min' }, { name: 'Max', calculation: 'array_max' }]
        column_strata = column_strata + [{ name: 'N', calculation: 'array_count' }, { name: '', value: nil }] if params[:column_include_missing].to_s == '1'

        column_strata.each do |stratum|
          scope = if stratum[:calculation].blank?
            sheet_scope.with_response_unknown_or_missing(@column_variable)
          else
            sheet_scope.with_any_variable_response_not_missing_code(@column_variable)
          end

          count = Sheet.array_calculation(scope, @column_variable, stratum[:calculation])

          @ranges <<  {
                        name: (((stratum[:value].blank? or stratum[:value] == stratum[:name]) ? '' : stratum[:value] + ": ") + stratum[:name]),
                        tooltip: stratum[:name],
                        start_date: '', end_date: '',
                        scope: scope,
                        count: count,
                        value: stratum[:value],
                        calculation: stratum[:calculation],
                        symbol: stratum[:symbol]
                      }
        end
      else # Default columns over Study Date
        if @column_variable and @column_variable.variable_type == 'date'
          min = Date.strptime(sheet_scope.sheet_responses(@column_variable).select{|response| not response.blank?}.min, "%Y-%m-%d") rescue min = Date.today
          max = Date.strptime(sheet_scope.sheet_responses(@column_variable).select{|response| not response.blank?}.max, "%Y-%m-%d") rescue max = Date.today
        else
          min = sheet_scope.collect{|s| s.created_at.to_date}.min || Date.today
          max = sheet_scope.collect{|s| s.created_at.to_date}.max || Date.today
        end

        case @by when "week"
          current_cweek = min.cweek
          (min.year..max.year).each do |year|
            (current_cweek..Date.parse("#{year}-12-28").cweek).each do |cweek|
              start_date = Date.commercial(year,cweek) - 1.day
              end_date = Date.commercial(year,cweek) + 5.days
              scope = sheet_scope.sheet_after_variable(@column_variable, start_date).sheet_before_variable(@column_variable, end_date)
              @ranges << { name: "Week #{cweek}", tooltip: "#{year} #{start_date.strftime("%m/%d")}-#{end_date.strftime("%m/%d")} Week #{cweek}", start_date: start_date, end_date: end_date, scope: scope, count: scope.count, value: "No Missing" }
              break if year == max.year and cweek == max.cweek
            end
            current_cweek = 1
          end
        when "month"
          current_month = min.month
          (min.year..max.year).each do |year|
            (current_month..12).each do |month|
              start_date = Date.parse("#{year}-#{month}-01")
              end_date = Date.parse("#{year}-#{month}-01").end_of_month
              scope = sheet_scope.sheet_after_variable(@column_variable, start_date).sheet_before_variable(@column_variable, end_date)
              @ranges << { name: "#{Date::ABBR_MONTHNAMES[month]} #{year}", tooltip: "#{Date::MONTHNAMES[month]} #{year}", start_date: start_date, end_date: end_date, scope: scope, count: scope.count, value: "No Missing" }
              break if year == max.year and month == max.month
            end
            current_month = 1
          end
        when "year"
          (min.year..max.year).each do |year|
            start_date = Date.parse("#{year}-01-01")
            end_date = Date.parse("#{year}-12-31")
            scope = sheet_scope.sheet_after_variable(@column_variable, start_date).sheet_before_variable(@column_variable, end_date)
            @ranges << { name: year.to_s, tooltip: year.to_s, start_date: start_date, end_date: end_date, scope: scope, count: scope.count, value: "No Missing" }
          end
        end
        if @column_variable and @column_variable.variable_type == 'date' and params[:column_include_missing].to_s == '1'
          scope = sheet_scope.with_stratum(@column_variable, nil)
          @ranges << { name: '', tooltip: '', start_date: '', end_date: '', scope: scope, count: scope.count, value: nil }
        end
      end

      # Row Stratification by Site (default) or by Variable on Design (currently supported: radio, dropdown, and string)
      if @variable
        @strata = @variable.options_or_autocomplete(params[:include_missing].to_s == '1')
        @strata = @strata + [{ name: '', value: nil }] if params[:include_missing].to_s == '1'
      else
        # @strata = (@design.project ? @design.project.sites.order('name').collect{|s| { name: s.name, value: s.id }} : [])
        @strata = (@design.project ? current_user.all_viewable_sites.with_project(@design.project.id).order('name').collect{|s| { name: s.name, value: s.id }} : [])
      end

      date_description = ((@column_variable and @column_variable.variable_type.include?('date')) ? @column_variable.display_name : 'Created')

      @report_caption = if @sheet_after.blank? and @sheet_before.blank?
        "All Sheets"
      elsif @sheet_after.blank?
        "#{date_description} before #{@sheet_before.strftime("%b %d, %Y")}"
      elsif @sheet_before.blank?
        "#{date_description} after #{@sheet_after.strftime("%b %d, %Y")}"
      else
        "#{date_description} between #{@sheet_after.strftime("%b %d, %Y")} and #{@sheet_before.strftime("%b %d, %Y")}"
      end

      @report_title = "#{@variable ? @variable.display_name : 'Site'} vs. #{@column_variable ? @column_variable.display_name : date_description}"

      @sheets = sheet_scope
    end
end
