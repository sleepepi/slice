module SheetExport
  extend ActiveSupport::Concern

  def generate_csv_sheets(sheet_scope, filename, raw_data, folder)
    sheet_ids = sheet_scope.pluck(:id)
    sheet_scope = nil # Freeing Memory
    generate_csv_sheets_internal(sheet_ids, filename, raw_data, folder)
  end

  private

  def generate_csv_sheets_internal(sheet_ids, filename, raw_data, folder)
    export_file = File.join('tmp', 'files', 'exports', "#{filename}_#{raw_data ? 'raw' : 'labeled'}.csv")

    CSV.open(export_file, 'wb') do |csv|
      variables = all_design_variables_without_grids_using_design_ids(Sheet.where(id: sheet_ids).select(:design_id))

      write_csv_header(csv, variables.collect(&:csv_column).flatten)
      write_csv_body(sheet_ids, csv, raw_data, variables)

      variables = nil # Freeing Memory
    end
    ["#{folder.upcase}/#{export_file.split('/').last}", export_file]
  end

  def write_csv_header(csv, column_headers)
    csv << ['Sheet ID', 'Name', 'Description', 'Sheet Creation Date', 'Project', 'Site', 'Subject', 'Acrostic', 'Status', 'Creator', 'Event Name'] + column_headers
  end

  def write_csv_body(sheet_ids, csv, raw_data, variables)
    sheet_ids.sort.reverse.each do |sheet_id|
      sheet = Sheet.includes(:project, :user, :subject_event, subject: [:site]).find_by_id sheet_id
      write_sheet_to_csv(csv, sheet, variables, raw_data) if sheet
      sheet = nil # Freeing Memory
      update_steps(1)
    end
  end

  def write_sheet_to_csv(csv, sheet, variables, raw_data)
    row = [ sheet.id,
            sheet.name,
            sheet.description,
            sheet.created_at.strftime('%Y-%m-%d'),
            sheet.project.name,
            sheet.subject.site.name,
            sheet.subject.name,
            sheet.project.acrostic_enabled? ? sheet.subject.acrostic : nil,
            sheet.subject.status,
            sheet.user ? sheet.user.name : nil,
            sheet.subject_event ? sheet.subject_event.name : nil ]

    sheet_variables = sheet.sheet_variables.includes(variable: [:domain]).to_a
    variables.each do |variable|
      sheet_variable = sheet_variables.select{ |sv| sv.variable_id == variable.id }.first
      response = if sheet_variable
        sheet_variable.get_response(raw_data ? :raw : :name)
      elsif variable.variable_type == 'checkbox'
        ['']
      else
        ''
      end

      row << (response.is_a?(Array) ? response.join(',') : response)
      if variable.variable_type == 'checkbox'
        variable.shared_options.each_with_index do |option, index|
          search_string = (raw_data ? option[:value] : "#{option[:value]}: #{option[:name]}")
          if response.include?(search_string)
            row << search_string
          else
            row << nil
          end
        end
      end
    end
    csv << row
    row = nil # Freeing Memory
  end

  def all_design_variables_without_grids_using_design_ids(design_ids)
    Variable.current.joins(:design_options).where(design_options: { design_id: design_ids }).where.not(variable_type: 'grid').order('design_options.design_id', 'design_options.position')
    # Design.where(id: design_ids).order(:id).collect(&:variables).flatten.uniq.select{|v| v.variable_type != 'grid'}
  end
end
