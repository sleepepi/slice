module Buildable
  extend ActiveSupport::Concern

  # included do
  #   scope :current, -> { where deleted: false }
  # end

  private

  # Returns the "Structure" of the report, leaving the evaluation to the view

  # Ex:
  #    Row variables
  #       Site
  #       Gender
  #    Column variables
  #       Body Mass Index - (calculatable...)
  #       Race

  # Resulting Table
  #               |                                  Body Mass Index (Race)
  # Site | Gender | Mean (White) | Stddev (White) | Stddev (Black) | Avg (Black) | Total (White) | Total (Black) |  Total
  #               |---------------------------------------------------------------------------------------------------------
  #  A   | Male   |   (see x1)   |                |                |             |               |               |          |
  #  A   | Female |              |    (see x2)    |                |             |               |               | (see x3) |
  #  B   | Male   |              |                |                |             |               |               |          |
  #  B   | Female |              |                |                |             |               |               |          |
  # ------------------------------------------------------------------------------------------------------------------------
  #  A   |  ---   |              |                |                |             |               |               |          |
  #  B   |  ---   |              |                |                |             |               |               |          |
  #  --- | Male   |              |                |                |             |               |               |          |
  #  --- | Female |              |                |                |             |               |               |          |
  # ------------------------------------------------------------------------------------------------------------------------
  # Total         |              |                |    (see x4)    |             |               |    (see x5)   | (see x6) |
  # ------------------------------------------------------------------------------------------------------------------------

  # x1 = site: a, gender: m, race: w, calculator: bmi, calculation: mean
  # x2 = site: a, gender: f, race: w, calculator: bmi, calculation: avg
  # x3 = site: a, gender: f,                           calculation: count (default)
  # x4 =                     race: b, calculator: bmi, calculation: mean
  # x5 =                     race: b,                  calculation: count (default)
  # x6 =                                               calculation: count (default)

  # Essentially will be adding together filters (row and column) along with specifying an item to count (calculate in the case of a numeric/integer variable), calculator will always be based on the first column variable.

  # Resulting Table
  #               |                   Race
  # Site | Gender |    White     |    Black    |    Total
  #               |--------------------------------------------
  #    A | Male   |   (see x1)   |             |              |
  #    A | Female |              |  (see x2)   |              |
  #    B | Male   |              |             |              |
  #    B | Female |              |             |              |
  # Total         |   (see x3)   |             |  (see x4)    |
  # -----------------------------------------------------------

  #      |=        FILTERS         =|
  # x1 = site: a, gender: m, race: w, calculator: race, calculation: count
  # x2 = site: a, gender: f, race: b, calculator: race, calculation: count
  # x3 =                     race: w, calculator: race, calculation: count
  # x4 =                              calculator: race, calculation: count


  def setup_report_new
    filters = (params[:f] || [{ id: 'site', axis: 'row', missing: '0' }, { id: 'sheet_date', axis: 'col', missing: '0', by: 'month' }]).uniq {|f| f[:id] }
    # filters = (params[:f] || []).uniq {|f| f[:id] }

    filters.collect!{|h| h.merge(variable: @project.variable_by_id(h[:id]))}.select!{|h| not h[:variable].blank?}

    @column_filters = filters.select{|f| f[:axis] == 'col' }[0..0]
    @row_filters = filters.select{|f| f[:axis] != 'col' }[0..2]





    # params[:row_variable_ids] = 'site' if params[:row_variable_ids].blank?


    params[:column_variable_ids] = params[:column_variable_id].to_s.split(',')[0]
    # params[:row_variable_ids] = params[:row_variable_ids].to_s.split(',') unless params[:row_variable_ids].kind_of?(Array)
    # params[:row_variable_ids] = params[:row_variable_ids][0..2] if params[:row_variable_ids].kind_of?(Array)
    params[:page] = (params[:page].to_i < 1 ? 1 : params[:page].to_i)

    set_sheet_scope

    if @design

      set_row_variables

      # @column_variables = @design.pure_variables.where(id: params[:column_variable_ids]).sort{ |a, b| params[:column_variable_ids].index(a.id.to_s) <=> params[:column_variable_ids].index(b.id.to_s) }

      build_row_strata



      build_table_header
      build_table_footer

      build_table_body


      # @ranges = [{ name: "2012", start_date: "2012-01-01", end_date: "2012-12-31" }, { name: "2013", start_date: "2013-01-01", end_date: "2013-12-31" }]
      # @ranges = []

      # if @column_variable and ['dropdown', 'radio', 'string'].include?(@column_variable.variable_type)
      #   column_strata = @column_variable.options_or_autocomplete(params[:column_include_missing].to_s == '1')
      #   column_strata = column_strata + [{ name: '', value: nil }] if params[:column_include_missing].to_s == '1'
      #   column_strata.each do |stratum|
      #     scope = @sheets.with_stratum(@column_variable, stratum[:value])
      #     @ranges << { name: (((stratum[:value].blank? or stratum[:value] == stratum[:name]) ? '' : stratum[:value] + ": ") + stratum[:name]), tooltip: stratum[:name], start_date: '', end_date: '', scope: scope, count: scope.count, value: stratum[:value], calculation: 'array_count' }
      #   end
      # elsif @column_variable and @column_variable.has_statistics?
      #   column_strata = [{ name: 'Mean', calculation: 'array_mean' }, { name: 'StdDev', calculation: 'array_standard_deviation', symbol: 'pm' }, { name: 'Median', calculation: 'array_median' }, { name: 'Min', calculation: 'array_min' }, { name: 'Max', calculation: 'array_max' }]
      #   column_strata = column_strata + [{ name: 'N', calculation: 'array_count' }, { name: '', value: nil }] if params[:column_include_missing].to_s == '1'

      #   column_strata.each do |stratum|
      #     scope = if stratum[:calculation].blank?
      #       @sheets.with_response_unknown_or_missing(@column_variable)
      #     else
      #       @sheets.with_any_variable_response_not_missing_code(@column_variable)
      #     end

      #     count = Sheet.array_calculation(scope, @column_variable, stratum[:calculation])

      #     @ranges <<  {
      #                   name: (((stratum[:value].blank? or stratum[:value] == stratum[:name]) ? '' : stratum[:value] + ": ") + stratum[:name]),
      #                   tooltip: stratum[:name],
      #                   start_date: '', end_date: '',
      #                   scope: scope,
      #                   count: count,
      #                   value: stratum[:value],
      #                   calculation: stratum[:calculation],
      #                   symbol: stratum[:symbol]
      #                 }
      #   end
      # else # Default columns over Study Date
      #   if @column_variable and @column_variable.variable_type == 'date'
      #     min = Date.strptime(@sheets.sheet_responses(@column_variable).select{|response| not response.blank?}.min, "%Y-%m-%d") rescue min = Date.today
      #     max = Date.strptime(@sheets.sheet_responses(@column_variable).select{|response| not response.blank?}.max, "%Y-%m-%d") rescue max = Date.today
      #   else
      #     min = @sheets.pluck("sheets.study_date").min || Date.today
      #     max = @sheets.pluck("sheets.study_date").max || Date.today
      #   end

      #   case @by when "week"
      #     current_cweek = min.cweek
      #     (min.year..max.year).each do |year|
      #       (current_cweek..Date.parse("#{year}-12-28").cweek).each do |cweek|
      #         start_date = Date.commercial(year,cweek) - 1.day
      #         end_date = Date.commercial(year,cweek) + 5.days
      #         scope = @sheets.sheet_after_variable(@column_variable, start_date).sheet_before_variable(@column_variable, end_date)
      #         @ranges << { name: "Week #{cweek}", tooltip: "#{year} #{start_date.strftime("%m/%d")}-#{end_date.strftime("%m/%d")} Week #{cweek}", start_date: start_date, end_date: end_date, scope: scope, count: scope.count, value: "No Missing" }
      #         break if year == max.year and cweek == max.cweek
      #       end
      #       current_cweek = 1
      #     end
      #   when "month"
      #     current_month = min.month
      #     (min.year..max.year).each do |year|
      #       (current_month..12).each do |month|
      #         start_date = Date.parse("#{year}-#{month}-01")
      #         end_date = Date.parse("#{year}-#{month}-01").end_of_month
      #         scope = @sheets.sheet_after_variable(@column_variable, start_date).sheet_before_variable(@column_variable, end_date)
      #         @ranges << { name: "#{Date::ABBR_MONTHNAMES[month]} #{year}", tooltip: "#{Date::MONTHNAMES[month]} #{year}", start_date: start_date, end_date: end_date, scope: scope, count: scope.count, value: "No Missing" }
      #         break if year == max.year and month == max.month
      #       end
      #       current_month = 1
      #     end
      #   when "year"
      #     (min.year..max.year).each do |year|
      #       start_date = Date.parse("#{year}-01-01")
      #       end_date = Date.parse("#{year}-12-31")
      #       scope = @sheets.sheet_after_variable(@column_variable, start_date).sheet_before_variable(@column_variable, end_date)
      #       @ranges << { name: year.to_s, tooltip: year.to_s, start_date: start_date, end_date: end_date, scope: scope, count: scope.count, value: "No Missing" }
      #     end
      #   end
      #   if @column_variable and @column_variable.variable_type == 'date' and params[:column_include_missing].to_s == '1'
      #     scope = @sheets.with_stratum(@column_variable, nil)
      #     @ranges << { name: '', tooltip: '', start_date: '', end_date: '', scope: scope, count: scope.count, value: nil }
      #   end
      # end

      # # Row Stratification by Site (default) or by Variable on Design (currently supported: radio, dropdown, and string)
      # if @variable
      #   @strata = @variable.options_or_autocomplete(params[:include_missing].to_s == '1')
      #   @strata = @strata + [{ name: '', value: nil }] if params[:include_missing].to_s == '1'
      # else
      #   # @strata = (@design.project ? @design.project.sites.order('name').collect{|s| { name: s.name, value: s.id }} : [])
      #   @strata = (@design.project ? current_user.all_viewable_sites.with_project(@design.project.id).order('name').collect{|s| { name: s.name, value: s.id }} : [])
      # end

      date_description = ((@column_variable and @column_variable.variable_type.include?('date')) ? @column_variable.display_name : 'Sheet Creation Date')

      @report_caption = if @sheet_after.blank? and @sheet_before.blank?
        "All Sheets"
      elsif @sheet_after.blank?
        "#{date_description} before #{@sheet_before.strftime("%b %d, %Y")}"
      elsif @sheet_before.blank?
        "#{date_description} after #{@sheet_after.strftime("%b %d, %Y")}"
      else
        "#{date_description} between #{@sheet_after.strftime("%b %d, %Y")} and #{@sheet_before.strftime("%b %d, %Y")}"
      end

      @report_title = [@row_variables.collect{|i| i[:variable].display_name}.join(' & '), @column_filters.collect{|h| h[:variable].display_name}.join(' & ')].select{ |i| not i.blank? }.join(' vs. ')

      @report_subtitle = (@design ? @design.name + " &middot; " + @design.project.name : '')
    end
  end

  def set_sheet_scope
    @sheet_before = parse_date(params[:sheet_before])
    @sheet_after = parse_date(params[:sheet_after])

    @by = ["week", "month", "year"].include?(params[:by]) ? params[:by] : "month" # "month" or "year"
    @percent = ['none', 'row', 'column'].include?(params[:percent]) ? params[:percent] : 'none'
    @filter = ['all', 'first', 'last'].include?(params[:filter]) ? params[:filter] : 'all'
    @statuses = params[:statuses] || ['valid']

    sheet_scope = current_user.all_viewable_sheets
    sheet_scope = sheet_scope.where(design_id: @design.id) if @design

    sheet_scope = sheet_scope.last_entry if @filter == 'last'
    sheet_scope = sheet_scope.first_entry if @filter == 'first'

    # Should be handled elsewhere...
    # sheet_scope = sheet_scope.sheet_after_variable_with_blank(@column_variable, @sheet_after) unless @sheet_after.blank?
    # sheet_scope = sheet_scope.sheet_before_variable_with_blank(@column_variable, @sheet_before) unless @sheet_before.blank?

    # Should be handled in the view, could depend on multiple
    # sheet_scope = sheet_scope.with_any_variable_response_not_missing_code(@variable) if @variable and params[:include_missing] != '1'
    # sheet_scope = sheet_scope.with_any_variable_response_not_missing_code(@column_variable) if @column_variable and params[:column_include_missing] != '1'

    sheet_scope = sheet_scope.with_subject_status(@statuses)
    @sheets = sheet_scope
  end

  def set_row_variables

    @row_variables = []
    @row_filters.each do |filter|
      @row_variables << { variable: filter[:variable], include_missing: (filter[:missing] == '1') }

      # if variable_id == 'site'
      #   @row_variables << { variable: Variable.site(@design.project_id), include_missing: false }
      # else
      #   variable = @design.pure_variables.find_by_id(variable_id)
      #   @row_variables << { variable: variable, include_missing: params[:row_include_missing].to_s == '1' } if variable
      # end
    end



    # @row_variables = []
    # params[:row_variable_ids].each do |variable_id|
    #   if variable_id == 'site'
    #     @row_variables << { variable: Variable.site(@design.project_id), include_missing: false }
    #   else
    #     variable = @design.pure_variables.find_by_id(variable_id)
    #     @row_variables << { variable: variable, include_missing: params[:row_include_missing].to_s == '1' } if variable
    #   end
    # end
  end

  def build_row_strata
    max_strata = 0
    max_strata = 50 if @row_variables.size == 3
    max_strata = 300 if @row_variables.size == 2

    @row_strata = []
    @row_variables.each do |hash|
      strata = hash[:variable].report_strata(hash[:include_missing], max_strata)
      unless strata.blank?
        if @row_strata.blank?
          @row_strata = strata.collect{|i| [i]}
        else
          @row_strata = @row_strata.product(strata).collect{ |i| i.flatten }
        end
      end
    end

    @per_page = 20

    @total_rows = @row_strata.size
    params[:page] = 1 if (params[:page]-1) * @per_page >= @total_rows
    @row_strata = @row_strata[(params[:page] - 1) * @per_page..(params[:page] * @per_page) - 1]
  end

  def build_table_header
    @table_header = @row_variables.collect{ |h| h[:variable].display_name }

    @column_filters.each do |filter|
      @table_header += filter[:variable].report_strata(filter[:missing] == '1')
    end
    # @column_variables.each do |v|
    #   @table_header += v.report_strata(true) # include missing is here for params[:column_variable_ids]
    # end
    @table_header << { name: 'Total', calculation: 'array_count' }
  end

  def build_table_footer
    table_row = []
    table_row = [{ name: 'Total', colspan: @row_variables.size }] if @row_variables.size > 0
    table_row += build_row

    calculator = @column_filters.first[:variable] if @column_filters.first
    (values, chart_type) = if calculator and calculator.has_statistics?
      [Sheet.array_responses_with_filters(@sheets, calculator, []), 'box']
    else
      [table_row.collect{|cell| cell[:count]}.compact, 'line']
    end

    @table_footer = { cells: table_row, values: values, chart_type: chart_type }
  end

  def build_table_body
    calculator = @column_filters.first[:variable] if @column_filters.first
    @table_body = []
    @row_strata.each do |row_stratum|
      table_row = []
      table_row += row_stratum.collect{ |info| { name: info[:name] } }
      filters = row_stratum.collect{|info| info[:filters] }.flatten
      table_row += build_row(filters)
      (values, chart_type) = if calculator and calculator.has_statistics?
        [Sheet.array_responses_with_filters(@sheets, calculator, filters), 'box']
      else
        [table_row.collect{|cell| cell[:count]}.compact, 'line']
      end
      @table_body << { cells: table_row, values: values, chart_type: chart_type }
    end
    @table_body
  end

  def build_row(filters = [])
    table_row = []

    @table_header.each do |header|
      if header.kind_of?(Hash)
        cell = header.dup
        cell[:filters] = (cell[:filters] || []) + filters
        (cell[:name], cell[:count]) = Sheet.array_calculation_with_filters(@sheets, cell[:calculator], cell[:calculation], cell[:filters])
        # cell[:debug] = '1'
        table_row << cell
      end
    end

    table_row
  end

  def generate_table_csv_new
    @csv_string = CSV.generate do |csv|
      csv << [@report_title]
      csv << [@report_subtitle.gsub("&middot;", " - ")]
      csv << [@report_caption]
      csv << []

      row = []
      @table_header.each do |header|
        if header.kind_of?(Hash)
          row << (header[:name].blank? ? 'Unknown' : header[:name].to_s)
        else
          row << header
        end
      end
      csv << row

      @table_body.each do |body|
        row = []
        body[:cells].each do |hash|
          row << (hash[:name].blank? ? 'Unknown' : hash[:name].to_s)
        end
        csv << row
      end

      row = []
      @table_footer[:cells].each do |hash|
        if hash[:colspan].blank?
           row << (hash[:name].blank? ? 'Unknown' : hash[:name].to_s)
        else
          row << hash[:name]
          ([""]*(hash[:colspan] - 1)).each do |item|
            row << item
          end
        end
      end
      csv << row


    end
    file_name = @report_title.gsub('vs.', 'versus').gsub(/[^\da-zA-Z ]/, '')
    send_data @csv_string, type: 'text/csv; charset=iso-8859-1; header=present',
                           disposition: "attachment; filename=\"#{file_name} #{Time.now.strftime("%Y.%m.%d %Ih%M %p")}.csv\""
  end

end
