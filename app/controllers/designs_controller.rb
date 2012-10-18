class DesignsController < ApplicationController
  before_filter :authenticate_user!

  def report_print
    @design = current_user.all_viewable_designs.find_by_id(params[:id])

    setup_report

    orientation = ['Portrait', 'Landscape'].include?(params[:orientation].to_s.capitalize) ? params[:orientation].to_s.capitalize : 'Portrait'

    if @design
      html = render_to_string( layout: false, action: 'report_print' )

      pdf_attachment = begin
        kit = PDFKit.new(html, orientation: orientation)
        stylesheet_file = "#{Rails.root}/public/assets/application.css"
        kit.stylesheets << "#{Rails.root}/public/assets/application.css" if File.exists?(stylesheet_file)
        kit.to_pdf
      rescue
        render nothing: true
        return
      end

      file_name = @report_title.gsub(' vs. ', ' versus ').gsub(/[^\da-zA-Z ]/, '')
      send_data(pdf_attachment, filename: "#{file_name} #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.pdf", type: 'application/pdf')
    else
      render nothing: true
    end
  end

  def report
    @design = current_user.all_viewable_designs.find_by_id(params[:id])

    setup_report

    if @design
      if params[:format] == 'csv'
        generate_table_csv(@design, @sheets, @ranges, @strata, @variable, @column_variable, @report_title, @report_caption)
        return
      end
    end

    respond_to do |format|
      if @design
        format.html # report.html.erb
        format.json { render json: @design }
        format.js { render 'report' }
      else
        format.html { redirect_to designs_path }
        format.json { head :no_content }
        format.js { render nothing: true }
      end
    end
  end


  def copy
    design = current_user.all_viewable_designs.find_by_id(params[:id])
    respond_to do |format|
      if design and @design = current_user.designs.new(design.copyable_attributes)
        format.html { render 'new' }
        format.json { render json: @design }
      else
        format.html { redirect_to designs_path }
        format.json { head :no_content }
      end
    end
  end

  def selection
    params[:current_design_page] = (params[:current_design_page].blank? ? 1 : params[:current_design_page].to_i)
    @sheet = current_user.all_sheets.find_by_id(params[:sheet_id])
    @sheet = Sheet.new unless @sheet
    @design = current_user.all_viewable_designs.find_by_id(params[:sheet][:design_id])
  end

  def add_section
    @design = Design.new(post_params.except(:option_tokens))
    @option = { }
  end

  def add_variable
    @design = Design.new(post_params)
    @option = { variable_id: '' }
    @all_viewable_variables = current_user.all_viewable_variables
    @select_variables = @all_viewable_variables.order(:project_id, :name).collect{|v| [v.name_with_project, v.id]}
  end

  def variables
    @design = Design.new(params[:design])
  end

  def reorder
    @design = current_user.all_designs.find_by_id(params[:id])
    if @design
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

  # GET /designs
  # GET /designs.json
  def index
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
        redirect_to designs_path, alert: 'No data was exported since no designs matched the specified filters.'
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
    end
  end

  def print
    @design = current_user.all_viewable_designs.find_by_id(params[:id])
    if @design
      render layout: false
    else
      render nothing: true
    end
  end

  # GET /designs/1
  # GET /designs/1.json
  def show
    @design = current_user.all_viewable_designs.find_by_id(params[:id])

    respond_to do |format|
      if @design
        format.html # show.html.erb
        format.json { render json: @design }
      else
        format.html { redirect_to designs_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /designs/new
  # GET /designs/new.json
  def new
    @design = current_user.designs.new(post_params)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @design }
    end
  end

  # GET /designs/1/edit
  def edit
    @design = current_user.all_designs.find_by_id(params[:id])
    redirect_to designs_path unless @design
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
    @design = current_user.all_designs.find_by_id(params[:id])

    respond_to do |format|
      if @design
        if @design.update_attributes(post_params)
          format.html { redirect_to @design, notice: 'Design was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @design.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to designs_path }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /designs/1
  # DELETE /designs/1.json
  def destroy
    @design = current_user.all_designs.find_by_id(params[:id])
    @design.destroy if @design

    respond_to do |format|
      format.html { redirect_to designs_path }
      format.js { render 'destroy' }
      format.json { head :no_content }
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

  def post_params
    params[:design] ||= {}

    params[:design][:updater_id] = current_user.id

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

      # @ranges = [{ name: "2012", start_date: "2012-01-01", end_date: "2012-12-31" }, { name: "2013", start_date: "2013-01-01", end_date: "2013-12-31" }]
      @ranges = []

      if @column_variable and ['dropdown', 'radio', 'string'].include?(@column_variable.variable_type)
        column_strata = @column_variable.options_or_autocomplete(params[:column_include_missing].to_s == '1')
        column_strata = column_strata + [{ name: '', value: nil }] if params[:column_include_missing].to_s == '1'
        column_strata.each do |stratum|
          scope = sheet_scope.with_stratum(@column_variable, stratum[:value])
          @ranges << { name: (((stratum[:value].blank? or stratum[:value] == stratum[:name]) ? '' : stratum[:value] + ": ") + stratum[:name]), tooltip: stratum[:name], start_date: '', end_date: '', scope: scope, count: scope.count, value: stratum[:value] }
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
