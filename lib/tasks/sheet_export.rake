desc "Generate file for sheet exports"
task sheet_export: :environment do
  export = Export.find_by_id(ENV["EXPORT_ID"])
  sheet_scope = Sheet.current.where(id: ENV["SHEET_IDS"].to_s.split(','))

  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet::Workbook.new

  [false, true].each do |raw_data|
    worksheet = book.create_worksheet name: "Sheets - #{raw_data ? 'RAW' : 'Labeled'}"
    variable_names = sheet_scope.collect(&:variables).flatten.uniq.collect{|v| [v.name, 'String']}.uniq

    current_row = 0

    worksheet.row(current_row).replace ["Name", "Description", "Sheet Date", "Project", "Site", "Subject", "Acrostic", "Creator"] + variable_names.collect{|v| v[0]}

    sheet_scope.each do |s|
      current_row += 1
      worksheet.row(current_row).push s.name, s.description, (s.study_date.blank? ? '' : s.study_date.strftime("%m-%d-%Y")), s.project.name, s.subject.site.name, s.subject.name, (s.project.acrostic_enabled? ? s.subject.acrostic : nil), s.user.name

      variable_names.each do |name, type|
        value = if variable = s.variables.find_by_name(name)
          raw_data ? variable.response_raw(s) : (variable.variable_type == 'checkbox' ? variable.response_name(s).join(',') : variable.response_name(s))
        else
          ''
        end
        worksheet.row(current_row).push value
      end
    end


    current_row = 0

    worksheetgrid = book.create_worksheet name: "Grids - #{raw_data ? 'RAW' : 'Labeled'}"

    variable_ids = SheetVariable.where(sheet_id: sheet_scope.pluck(:id)).collect(&:variable_id)
    grid_group_variables = Variable.current.where(variable_type: 'grid', id: variable_ids)
    # @grids = sheet_scope.collect(&:sheet_variables).flatten.collect(&:grids).flatten.compact.uniq

    worksheetgrid.row(current_row).replace ["", "", "", "", "", "", "", ""]

    grid_group_variables.each do |variable|
      variable.grid_variables.each do |grid_variable_hash|
        grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
        worksheetgrid.row(current_row).push variable.name if grid_variable
      end
    end

    current_row += 1
    worksheetgrid.row(current_row).replace ["Name", "Description", "Sheet Date", "Project", "Site", "Subject", "Acrostic", "Creator"]

    grid_group_variables.each do |variable|
      variable.grid_variables.each do |grid_variable_hash|
        grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
        worksheetgrid.row(current_row).push grid_variable.name if grid_variable
      end
    end

    sheet_scope.each do |s|
      (0..s.max_grids_position).each do |position|
        current_row += 1
        worksheetgrid.row(current_row).push s.name, s.description, (s.study_date.blank? ? '' : s.study_date.strftime("%m-%d-%Y")), s.project.name, s.subject.site.name, s.subject.name, (s.project.acrostic_enabled? ? s.subject.acrostic : nil), s.user.name

        grid_group_variables.each do |variable|
          variable.grid_variables.each do |grid_variable_hash|
            sheet_variable = s.sheet_variables.find_by_variable_id(variable.id)
            result_hash = (sheet_variable ? sheet_variable.response_hash(position, grid_variable_hash[:variable_id]) : {})
            cell = if raw_data
              result_hash.kind_of?(Array) ? result_hash.collect{|h| h[:value]}.join(',') : result_hash[:value]
            else
              result_hash.kind_of?(Array) ? result_hash.collect{|h| "#{h[:value]}: #{h[:name]}"}.join(', ') : result_hash[:name]
            end
            worksheetgrid.row(current_row).push cell
          end
        end
      end
    end
  end

  filename = File.join('tmp', 'files', 'exports', "#{export.name.gsub(/[^a-zA-Z0-9_-]/, '_')} #{export.created_at.strftime("%I%M%P")}.xls")

  # buffer = StringIO.new
  book.write(filename)
  # buffer.rewind

  export.update_attributes file: File.open(filename), file_created_at: Time.now, status: 'ready'

  export.notify_user!
end
