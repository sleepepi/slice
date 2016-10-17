# frozen_string_literal: true

# Ex:
#    Row variables
#       Site
#       Gender
#    Column variables
#       Body Mass Index - (calculatable...)
#       Race

# Resulting Table
#               |                                  Body Mass Index (Race)
# Site | Gender | Mean (Wh) | Stddev (Wh) | Stddev (Bl) | Avg (Bl) | Total (Wh) | Total (Bl) |  Total   |
#               |------------------------------------------------------------------------------ ---------
#  A   | Male   |  (see x1) |             |             |          |            |            |          |
#  A   | Female |           |  (see x2)   |             |          |            |            | (see x3) |
#  B   | Male   |           |             |             |          |            |            |          |
#  B   | Female |           |             |             |          |            |            |          |
# -------------------------------------------------------------------------------------------------------
#  A   |  ---   |           |             |             |          |            |            |          |
#  B   |  ---   |           |             |             |          |            |            |          |
#  --- | Male   |           |             |             |          |            |            |          |
#  --- | Female |           |             |             |          |            |            |          |
# ------------------------------------------------------------------------------------------------------
# Total         |           |             |  (see x4)   |          |            |  (see x5)  | (see x6) |
# -------------------------------------------------------------------------------------------------------

# x1 = site: a, gender: m, race: w, calculator: bmi, calculation: mean
# x2 = site: a, gender: f, race: w, calculator: bmi, calculation: avg
# x3 = site: a, gender: f,                           calculation: count (default)
# x4 =                     race: b, calculator: bmi, calculation: mean
# x5 =                     race: b,                  calculation: count (default)
# x6 =                                               calculation: count (default)

# Essentially will be adding together filters (row and column) along with
# specifying an item to count (calculate in the case of a numeric/integer
# variable), calculator will always be based on the first column variable.

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

# Builds report tables for projects and designs
# Returns the structure of the report, leaving the evaluation to the view
module Buildable
  extend ActiveSupport::Concern

  private

  def setup_report_new
    default_filters = [{ id: 'site', axis: 'row', missing: '0' },
                       { id: 'sheet_date', axis: 'col', missing: '0', by: 'month' }]
    filters = (params[:f] || default_filters).uniq { |f| f[:id] }
    filters.collect! { |h| h.merge(variable: @project.variable_by_id(h[:id])) }.select! { |h| h[:variable].present? }
    @column_filters = filters.select { |f| f[:axis] == 'col' }[0..0]
    @row_filters = filters.select { |f| f[:axis] != 'col' }[0..2]
    params[:page] = (params[:page].to_i < 1 ? 1 : params[:page].to_i)
    set_sheet_scope
    build_row_strata
    build_table_header
    build_table_footer
    build_table_body
    @report_caption = 'All Sheets'
    @report_title = [
      @row_filters.collect { |i| i[:variable].display_name }.join(' & '),
      @column_filters.collect { |h| h[:variable].display_name }.join(' & ')
    ].select(&:present?).join(' vs. ')
    @report_subtitle = (@design ? @design.name + ' &middot; ' + @design.project.name : @project.name)
  end

  def set_sheet_scope
    @sheet_before = parse_date(params[:sheet_before])
    @sheet_after = parse_date(params[:sheet_after])
    @by = %w(week month year).include?(params[:by]) ? params[:by] : 'month'
    @percent = %w(none row column).include?(params[:percent]) ? params[:percent] : 'none'
    sheet_scope = current_user.all_viewable_sheets
    sheet_scope = sheet_scope.where(design_id: @design ? @design.id : @project.designs.pluck(:id))
    sheet_scope = sheet_scope.where(missing: false)
    @sheets = sheet_scope
  end

  def build_row_strata
    max_strata = 100
    max_strata = 50 if @row_filters.size == 3
    max_strata = 300 if @row_filters.size == 2

    @row_strata = []
    @row_filters.each do |hash|
      strata = hash[:variable].report_strata(hash[:missing] == '1', max_strata, hash, @sheets)

      @row_strata = if @row_strata.blank?
                      strata.collect { |i| [i] }
                    else
                      @row_strata.product(strata).collect(&:flatten)
                    end
    end

    @per_page = 20

    @total_rows = @row_strata.size
    params[:page] = 1 if (params[:page] - 1) * @per_page >= @total_rows
    @row_strata = @row_strata[(params[:page] - 1) * @per_page..(params[:page] * @per_page) - 1]
  end

  def build_table_header
    max_strata = 100
    @table_header = @row_filters.collect { |h| h[:variable].display_name }
    @column_filters.each do |filter|
      @table_header += filter[:variable].report_strata(filter[:missing] == '1', max_strata, filter, @sheets)
    end
    @table_header << { name: 'Total', tooltip: 'Total', calculation: 'array_count', column_type: 'total' }
  end

  def build_table_footer
    table_row = []
    table_row = [{ name: 'Total', colspan: @row_filters.size }] if @row_filters.size > 0

    # Add filters to total rows to remove additional missing counts if missing
    # is set as false for a particular row variable
    filters = @row_filters.select { |f| f[:missing] != '1' }
                          .select { |f| f[:id].to_i > 0 }
                          .collect { |f| { variable_id: f[:id], value: nil, operator: 'any' } }

    table_row += build_row(filters)

    calculator = @column_filters.first[:variable] if @column_filters.first
    (values, chart_type) = if calculator && calculator.statistics?
                             [Sheet.array_responses_with_filters(@sheets, calculator, filters, current_user), 'box']
                           else
                             [table_row.select { |cell| cell[:column_type] != 'total' }
                                       .collect { |cell| cell[:count] }.compact, 'line']
                           end

    @table_footer = { cells: table_row, values: values, chart_type: chart_type }
  end

  def build_table_body
    calculator = @column_filters.first[:variable] if @column_filters.first
    @table_body = []
    @row_strata.each do |row_stratum|
      table_row = []
      table_row += row_stratum.collect { |hash| { name: hash[:value].present? ? "#{hash[:value]}: #{hash[:name]}" : hash[:name], muted: hash[:muted] } }
      filters = row_stratum.collect { |hash| hash[:filters] }.flatten
      table_row += build_row(filters)
      (values, chart_type) = if calculator && calculator.statistics?
                               [Sheet.array_responses_with_filters(@sheets, calculator, filters, current_user), 'box']
                             else
                               [table_row.select { |cell| cell[:column_type] != 'total' }
                                         .collect { |cell| cell[:count] }.compact, 'line']
                             end
      @table_body << { cells: table_row, values: values, chart_type: chart_type }
    end
    @table_body
  end

  def build_row(filters = [])
    table_row = []

    @table_header.each do |header|
      next unless header.is_a?(Hash)
      cell = header.dup
      cell[:filters] = (cell[:filters] || []) + filters
      # This adds in row specific missing filters to accurately calculate the total row count
      cell[:filters] += @column_filters
                        .select { |f| f[:missing] != '1' }
                        .select { |f| f[:id].to_i > 0 }
                        .collect { |f| { variable_id: f[:id], value: nil, operator: 'any' } } if header[:column_type] == 'total'
      (cell[:name], cell[:count]) = Sheet.array_calculation_with_filters(@sheets, cell[:calculator], cell[:calculation], cell[:filters], current_user)
      # cell[:debug] = '1'
      table_row << cell
    end

    table_row
  end

  def generate_table_csv_new
    @csv_string = CSV.generate do |csv|
      csv << [@report_title]
      csv << [@report_subtitle.gsub('&middot;', ' - ')]
      csv << [@report_caption]
      csv << []

      row = []
      @table_header.each do |header|
        row << if header.is_a?(Hash)
                 (header[:name].blank? ? 'Missing' : header[:name].to_s)
               else
                 header
               end
      end
      csv << row

      @table_body.each do |body|
        row = []
        body[:cells].each do |hash|
          row << (hash[:name].blank? ? 'Missing' : hash[:name].to_s)
        end
        csv << row
      end

      row = []
      @table_footer[:cells].each do |hash|
        if hash[:colspan].blank?
          row << (hash[:name].blank? ? 'Missing' : hash[:name].to_s)
        else
          row << hash[:name]
          ([''] * (hash[:colspan] - 1)).each do |item|
            row << item
          end
        end
      end
      csv << row
    end
    file_name = @report_title.gsub('vs.', 'versus').gsub(/[^\da-zA-Z ]/, '')
    send_data @csv_string,
              type: 'text/csv; charset=iso-8859-1; header=present',
              disposition: "attachment; filename=\"#{file_name} #{Time.zone.now.strftime('%Y.%m.%d %Ih%M %p')}.csv\""
  end
end
