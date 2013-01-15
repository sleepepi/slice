class DesignsController < ApplicationController
  before_filter :authenticate_user!

  def report_print
    @project = current_user.all_viewable_and_site_projects.find_by_id(params[:project_id])
    @design = current_user.all_viewable_designs.find_by_id(params[:id])

    setup_report

    orientation = ['portrait', 'landscape'].include?(params[:orientation].to_s) ? params[:orientation].to_s : 'portrait'

    if @project and @design
      file_pdf_location = @design.latex_report_file_location(current_user, @sheets, @report_title, @report_caption, @variable, @ranges, @percent, @strata, @column_variable, orientation)

      if File.exists?(file_pdf_location)
        File.open(file_pdf_location, 'r') do |file|
          file_name = @report_title.gsub(' vs. ', ' versus ').gsub(/[^\da-zA-Z ]/, '')
          send_file file, filename: "#{file_name} #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.pdf", type: "application/pdf", disposition: "inline"
        end
      else
        render text: "PDF did not render in time. Please refresh the page."
      end
    else
      render nothing: true
    end
  end

  def report
    @project = current_user.all_viewable_and_site_projects.find_by_id(params[:project_id])
    @design = current_user.all_viewable_designs.find_by_id(params[:id])

    setup_report

    if @project and @design
      if params[:format] == 'csv'
        generate_table_csv(@design, @sheets, @ranges, @strata, @variable, @column_variable, @report_title, @report_caption)
        return
      end
    end

    respond_to do |format|
      if @project and @design
        format.html # report.html.erb
        format.json { render json: @design }
        format.js { render 'report' }
      elsif @project
        format.html { redirect_to project_designs_path(@project) }
        format.json { head :no_content }
        format.js { render nothing: true }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
        format.js { render nothing: true }
      end
    end
  end


  def copy
    @project = current_user.all_projects.find_by_id(params[:project_id])
    design = current_user.all_viewable_designs.find_by_id(params[:id])
    @design = current_user.designs.new(design.copyable_attributes) if design
    respond_to do |format|
      if @project and @design
        format.html { render 'new' }
        format.json { render json: @design }
      elsif @project
        format.html { redirect_to project_designs_path(@project) }
        format.json { head :no_content }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
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
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @design = Design.new(post_params.except(:option_tokens))
    @option = { }
  end

  def add_variable
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @design = Design.new(post_params)
    @option = { variable_id: '' }
    @all_viewable_variables = current_user.all_viewable_variables.where(project_id: @project.id)
    @select_variables = @all_viewable_variables.order(:name).collect{|v| [v.name, v.id]}
  end

  def variables
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @design = Design.new(post_params)
  end

  def reorder
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @design = current_user.all_designs.find_by_id(params[:id])
    if @project and @design
      if params[:rows].blank?
        @design.reorder_sections(params[:sections].to_s.split(','), current_user)
      else
        @design.reorder(params[:rows].to_s.split(','), current_user)
      end
      render 'reorder'
    else
      render nothing: true
    end
  end

  def batch
    @project = current_user.all_projects.find_by_id(params[:project_id])
    if @project
      @designs = @project.designs
      @sites = @project.sites
      @emails = []
    else
      render nothing: true
    end
  end

  def create_batch
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @design = @project.designs.find_by_id(params[:design_id]) if @project
    @site = @project.sites.find_by_id(params[:site_id]) if @project
    @emails = params[:emails].to_s.split(/[;\r\n]/).collect{|email| email.strip}.select{|email| not email.blank?}.uniq
    @date = parse_date(params[:sheet_date])


    if @project
      if @design and @site and not @date.blank? and not @emails.blank?
        # @sheets = @design.batch_sheets!(current_user, @site, @date, @emails)
        # redirect_to project_sheets_path(@project, sheet_after: @date.strftime("%m/%d/%Y"), sheet_before: @date.strftime("%m/%d/%Y"), site_id: @site.id, design_id: @design.id, user_id: current_user.id), notice: "#{@sheets.count} #{@sheets.count == 1 ? 'sheet was' : 'sheets were'} successfully created."
        (sheets_created, sheets_ignored) = @design.batch_sheets!(current_user, @site, @date, @emails)
        flash[:notice] = "#{sheets_created} #{sheets_created == 1 ? 'sheet was' : 'sheets were'} successfully created." if sheets_created > 0
        flash[:alert] = "#{sheets_ignored} #{sheets_ignored == 1 ? 'sheet was' : 'sheets were'} not created because the #{sheets_ignored == 1 ? 'subject exists' : 'subjects exist'} on a different site." if sheets_ignored > 0
        redirect_to project_sheets_path(@project, sheet_after: @date.strftime("%m/%d/%Y"), sheet_before: @date.strftime("%m/%d/%Y"), site_id: @site.id, design_id: @design.id, user_id: current_user.id)
      else
        redirect_to batch_project_designs_path(emails: @emails.join('; '), date: @date.blank? ? nil : @date.strftime("%m/%d/%Y"), site_id: @site ? @site.id : nil, design_id: @design ? @design.id : nil ), alert: 'Please select a sheet date, design, site, and valid emails.'
      end
    else
      redirect_to root_path
    end
  end

  # GET /designs
  # GET /designs.json
  def index
    @project = current_user.all_projects.find_by_id(params[:project_id])
    if @project
      current_user.pagination_set!('designs', params[:designs_per_page].to_i) if params[:designs_per_page].to_i > 0
      design_scope = current_user.all_viewable_designs

      design_scope = design_scope.where(id: params[:design_ids]) unless params[:design_ids].blank?

      ['project', 'user'].each do |filter|
        design_scope = design_scope.send("with_#{filter}", params["#{filter}_id".to_sym]) unless params["#{filter}_id".to_sym].blank?
      end

      @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
      @search_terms.each{|search_term| design_scope = design_scope.search(search_term) }

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

      @design_count = design_scope.count

      if params[:format] == 'csv'
        if @design_count == 0
          redirect_to project_designs_path(@project), alert: 'No data was exported since no designs matched the specified filters.'
          return
        end
        generate_csv(design_scope)
        return
      end

      @designs = design_scope.page(params[:page]).per( current_user.pagination_count('designs') )

      respond_to do |format|
        format.html # index.html.erb
        format.js
        format.json { render json: @designs }
        format.xls { generate_xls(design_scope) }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # This is the latex view
  def print
    @project = current_user.all_viewable_and_site_projects.find_by_id(params[:project_id])
    @design = current_user.all_viewable_designs.find_by_id(params[:id])

    if @project and @design
      file_pdf_location = @design.latex_file_location(current_user)

      if File.exists?(file_pdf_location)
        File.open(file_pdf_location, 'r') do |file|
          send_file file, filename: "design_#{@design.id}.pdf", type: "application/pdf", disposition: "inline"
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
  #   @project = current_user.all_viewable_and_site_projects.find_by_id(params[:project_id])
  #   @design = current_user.all_viewable_designs.find_by_id(params[:id])
  #   if @project and @design
  #     render layout: false
  #   else
  #     render nothing: true
  #   end
  # end

  # GET /designs/1
  # GET /designs/1.json
  def show
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @design = current_user.all_viewable_designs.find_by_id(params[:id])

    respond_to do |format|
      if @project
        if @design
          format.html # show.html.erb
          format.json { render json: @design }
        else
          format.html { redirect_to project_designs_path(@project) }
          format.json { head :no_content }
        end
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /designs/new
  # GET /designs/new.json
  def new
    @design = current_user.designs.new(updater_id: current_user.id, project_id: params[:project_id])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @design }
    end
  end

  # GET /designs/1/edit
  def edit
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @design = current_user.all_designs.find_by_id(params[:id])

    if @project and @design
      render 'edit'
    elsif @project
      redirect_to project_designs_path(@project)
    else
      redirect_to root_path
    end
  end

  # POST /designs
  # POST /designs.json
  def create
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @design = current_user.designs.new(post_params)

    respond_to do |format|
      if @project
        if @design.save
          format.html { redirect_to [@design.project, @design], notice: 'Design was successfully created.' }
          format.json { render json: @design, status: :created, location: @design }
        else
          format.html { render action: "new" }
          format.json { render json: @design.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
      end
    end
  end

  # PUT /designs/1
  # PUT /designs/1.json
  def update
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @design = current_user.all_designs.find_by_id(params[:id])

    respond_to do |format|
      if @project
        if @design
          if @design.update_attributes(post_params)
            format.html { redirect_to [@design.project, @design], notice: 'Design was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: "edit" }
            format.json { render json: @design.errors, status: :unprocessable_entity }
          end
        else
          format.html { redirect_to project_designs_path(@project) }
          format.json { head :no_content }
        end
      else
        format.html { redirect_to root_path }
        format.js { render nothing: true }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /designs/1
  # DELETE /designs/1.json
  def destroy
    @project = current_user.all_projects.find_by_id(params[:project_id])
    @design = current_user.all_designs.find_by_id(params[:id])

    respond_to do |format|
      if @project
        @design.destroy if @design
        format.html { redirect_to project_designs_path(@project) }
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
        row_counts = ranges.collect{|hash| hash[:scope].with_stratum(variable, stratum[:value]).count }
        link_name = ((stratum[:value].blank? or stratum[:value] == stratum[:name]) ? '' :  "#{stratum[:value]}: ") + stratum[:name]
        row << (stratum[:name].blank? ? 'Unknown' : link_name)
        ranges.each do |hash|
          row << hash[:scope].with_stratum(variable, stratum[:value]).count
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
    export = current_user.exports.create(name: "#{current_user.last_name}_#{Date.today.strftime("%Y%m%d")}", project_id: @project.id, export_type: 'designs')

    design_ids = design_scope.pluck(:id)

    systemu "#{RAKE_PATH} design_export EXPORT_ID=#{export.id} DESIGN_IDS='#{design_ids.join(',')}' &"

    redirect_to project_designs_path(@project), notice: 'You will be emailed when the export is ready for download.'
  end

  def post_params
    params[:design] ||= {}

    params[:design][:updater_id] = current_user.id

    if current_user.all_projects.pluck(:id).include?(params[:project_id].to_i)
      params[:design][:project_id] = params[:project_id]
    else
      params[:design][:project_id] = nil
    end

    params[:design].slice(
      :name, :description, :project_id, :option_tokens, :email_template, :email_subject_template, :updater_id, :study_date_name
    )
  end

  def setup_report
    @sheet_before = parse_date(params[:sheet_before])
    @sheet_after = parse_date(params[:sheet_after])

    @by = ["week", "month", "year"].include?(params[:by]) ? params[:by] : "month" # "month" or "year"
    @percent = ['none', 'row', 'column'].include?(params[:percent]) ? params[:percent] : 'none'
    @filter = ['all', 'first', 'last'].include?(params[:filter]) ? params[:filter] : 'all'
    @statuses = params[:statuses] || ['valid']

    if @design
      @variable = @design.pure_variables.find_by_id(params[:variable_id])
      @column_variable = @design.pure_variables.find_by_id(params[:column_variable_id])

      sheet_scope = current_user.all_viewable_sheets.with_design(@design.id).scoped()
      # sheet_scope = @design.sheets.scoped()
      sheet_scope = sheet_scope.last_entry if @filter == 'last'
      sheet_scope = sheet_scope.first_entry if @filter == 'first'

      sheet_scope = sheet_scope.sheet_after_variable_with_blank(@column_variable, @sheet_after) unless @sheet_after.blank?
      sheet_scope = sheet_scope.sheet_before_variable_with_blank(@column_variable, @sheet_before) unless @sheet_before.blank?

      sheet_scope = sheet_scope.with_any_variable_response_not_missing_code(@variable) if @variable and params[:include_missing] != '1'
      sheet_scope = sheet_scope.with_any_variable_response_not_missing_code(@column_variable) if @column_variable and params[:column_include_missing] != '1'

      sheet_scope = sheet_scope.with_subject_status(@statuses)

      # @ranges = [{ name: "2012", start_date: "2012-01-01", end_date: "2012-12-31" }, { name: "2013", start_date: "2013-01-01", end_date: "2013-12-31" }]
      @ranges = []

      if @column_variable and ['dropdown', 'radio', 'string'].include?(@column_variable.variable_type)
        column_strata = @column_variable.options_or_autocomplete(params[:column_include_missing].to_s == '1')
        column_strata = column_strata + [{ name: '', value: nil }] if params[:column_include_missing].to_s == '1'
        column_strata.each do |stratum|
          scope = sheet_scope.with_stratum(@column_variable, stratum[:value])
          @ranges << { name: (((stratum[:value].blank? or stratum[:value] == stratum[:name]) ? '' : stratum[:value] + ": ") + stratum[:name]), tooltip: stratum[:name], start_date: '', end_date: '', scope: scope, count: scope.count, value: stratum[:value], calculation: 'array_count' }
        end
      elsif @column_variable and ['integer', 'numeric'].include?(@column_variable.variable_type)
        column_strata = [{ name: 'Mean', calculation: 'array_mean' }, { name: 'StdDev', calculation: 'array_standard_deviation' }, { name: 'Median', calculation: 'array_median' }, { name: 'Min', calculation: 'array_min' }, { name: 'Max', calculation: 'array_max' }, { name: 'N', calculation: 'array_count' }]
        column_strata = column_strata + [{ name: '', value: nil }] if params[:column_include_missing].to_s == '1'

        column_strata.each do |stratum|
          sheet_scope = if stratum[:calculation].blank?
            sheet_scope.with_response_unknown_or_missing(@column_variable)
          else
            sheet_scope.with_any_variable_response_not_missing_code(@column_variable)
          end

          # responses = Sheet.array_responses(sheet_scope, @column_variable)
          # count = Sheet.send(stratum[:calculation], responses)

          count = Sheet.array_calculation(sheet_scope, @column_variable, stratum[:calculation])

          @ranges <<  {
                        name: (((stratum[:value].blank? or stratum[:value] == stratum[:name]) ? '' : stratum[:value] + ": ") + stratum[:name]),
                        tooltip: stratum[:name],
                        start_date: '', end_date: '',
                        scope: sheet_scope,
                        count: count,
                        value: stratum[:value]
                      }
        end
      else # Default columns over Study Date
        if @column_variable and @column_variable.variable_type == 'date'
          min = Date.strptime(sheet_scope.sheet_responses(@column_variable).select{|response| not response.blank?}.min, "%Y-%m-%d") rescue min = Date.today
          max = Date.strptime(sheet_scope.sheet_responses(@column_variable).select{|response| not response.blank?}.max, "%Y-%m-%d") rescue max = Date.today
        else
          min = sheet_scope.pluck("sheets.study_date").min || Date.today
          max = sheet_scope.pluck("sheets.study_date").max || Date.today
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

      date_description = ((@column_variable and @column_variable.variable_type.include?('date')) ? @column_variable.display_name : @design.study_date_name_full)

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
end
