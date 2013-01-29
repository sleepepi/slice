require 'rubygems'
require 'zip/zip'

desc "Generate file for sheet exports"
task sheet_export: :environment do
  export = Export.find_by_id(ENV["EXPORT_ID"])
  sheet_scope = Sheet.current.where(id: ENV["SHEET_IDS"].to_s.split(','))

  begin
    filename = "#{export.name.gsub(/[^a-zA-Z0-9_-]/, '_')} #{export.created_at.strftime("%I%M%P")}"

    all_files = [] # If numerous files are created then they need to be zipped!

    all_files << generate_xls(export, sheet_scope, filename)                if export.include_xls?
    all_files << generate_csv_sheets(export, sheet_scope, filename, false)  if export.include_csv_labeled?
    all_files << generate_csv_grids(export, sheet_scope, filename, false)   if export.include_csv_labeled?
    all_files << generate_csv_sheets(export, sheet_scope, filename, true)   if export.include_csv_raw?
    all_files << generate_csv_grids(export, sheet_scope, filename, true)    if export.include_csv_raw?
    all_files << generate_pdf(export, sheet_scope, filename)                if export.include_pdf?
    all_files << generated_data_dictionary(export, sheet_scope, filename)   if export.include_data_dictionary?
    sheet_scope.each{ |sheet| all_files += sheet.files }                    if export.include_files?

    # Zip multiple files
    export_file = if all_files.size > 1
      # Create a zip file
      zipfile_name = File.join('tmp', 'files', 'exports', "#{filename}.zip")
      Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
        all_files.each do |location, input_file|
          # Two arguments:
          # - The name of the file as it will appear in the archive
          # - The original file, including the path to find it
          zipfile.add(location, input_file)
        end
      end
      zipfile_name
    elsif all_files.size == 1
      all_files.first[1]
    end

    if export_file.blank? and export.include_files?
      export.update_attributes status: 'failed', details: "No sheets have had files uploaded. Zip file not created."
    elsif export_file.blank?
      export.update_attributes status: 'failed', details: "No files were created. At least one file type needs to be selected for exports."
    else
      export.update_attributes file: File.open(export_file), file_created_at: Time.now, status: 'ready'
      export.notify_user!
    end
  rescue => e
    export.update_attributes status: 'failed', details: e.message.to_s + e.backtrace.to_s
    Rails.logger.debug "Error: #{e}"
    puts "Error: #{e.inspect}"
    puts e.backtrace
  end
end


def generate_xls(export, sheet_scope, filename)

  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet::Workbook.new

  [false, true].each do |raw_data|
    worksheet = book.create_worksheet name: "Sheets - #{raw_data ? 'RAW' : 'Labeled'}"

    # Only return variables currently on designs
    variable_names = Design.where(id: sheet_scope.pluck(:design_id)).collect(&:variables).flatten.uniq.collect{|v| [v.name, 'String']}.uniq
    current_row = 0
    worksheet.row(current_row).replace ["Name", "Description", "Sheet Date", "Project", "Site", "Subject", "Acrostic", "Status", "Creator"] + variable_names.collect{|v| v[0]}
    sheet_scope.each do |s|
      current_row += 1
      worksheet.row(current_row).push s.name, s.description, (s.study_date.blank? ? '' : s.study_date.strftime("%m-%d-%Y")), s.project.name, s.subject.site.name, s.subject.name, (s.project.acrostic_enabled? ? s.subject.acrostic : nil), s.subject.status, s.user.name
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

    worksheet = book.create_worksheet name: "Grids - #{raw_data ? 'RAW' : 'Labeled'}"



    variable_ids = Design.where(id: sheet_scope.pluck(:design_id)).collect(&:variable_ids).flatten.uniq
    # variable_ids = SheetVariable.where(sheet_id: sheet_scope.pluck(:id)).collect(&:variable_id)
    grid_group_variables = Variable.current.where(variable_type: 'grid', id: variable_ids)

    worksheet.row(current_row).replace ["", "", "", "", "", "", "", "", ""]

    grid_group_variables.each do |variable|
      variable.grid_variables.each do |grid_variable_hash|
        grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
        worksheet.row(current_row).push variable.name if grid_variable
      end
    end

    current_row += 1
    worksheet.row(current_row).replace ["Name", "Description", "Sheet Date", "Project", "Site", "Subject", "Acrostic", "Status", "Creator"]

    grid_group_variables.each do |variable|
      variable.grid_variables.each do |grid_variable_hash|
        grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
        worksheet.row(current_row).push grid_variable.name if grid_variable
      end
    end

    sheet_scope.each do |s|
      (0..s.max_grids_position).each do |position|
        current_row += 1
        worksheet.row(current_row).push s.name, s.description, (s.study_date.blank? ? '' : s.study_date.strftime("%m-%d-%Y")), s.project.name, s.subject.site.name, s.subject.name, (s.project.acrostic_enabled? ? s.subject.acrostic : nil), s.subject.status, s.user.name

        grid_group_variables.each do |variable|
          variable.grid_variables.each do |grid_variable_hash|
            sheet_variable = s.sheet_variables.find_by_variable_id(variable.id)
            result_hash = (sheet_variable ? sheet_variable.response_hash(position, grid_variable_hash[:variable_id]) : {})
            cell = if raw_data
              result_hash.kind_of?(Array) ? result_hash.collect{|h| h[:value]}.join(',') : result_hash[:value]
            else
              result_hash.kind_of?(Array) ? result_hash.collect{|h| "#{h[:value]}: #{h[:name]}"}.join(', ') : result_hash[:name]
            end
            worksheet.row(current_row).push cell
          end
        end
      end
    end
  end


  export_file = File.join('tmp', 'files', 'exports', "#{filename}.xls")

  # buffer = StringIO.new
  book.write(export_file)
  # buffer.rewind
  [export_file.split('/').last, export_file]
end

def generate_csv_sheets(export, sheet_scope, filename, raw_data)
  export_file = File.join('tmp', 'files', 'exports', "#{filename}_#{raw_data ? 'raw' : 'labeled'}.csv")

  CSV.open(export_file, "wb") do |csv|
    # Only return variables currently on designs
    variable_names = Design.where(id: sheet_scope.pluck(:design_id)).collect(&:variables).flatten.uniq.collect{|v| v.name}.uniq
    csv << ["Name", "Description", "Sheet Date", "Project", "Site", "Subject", "Acrostic", "Status", "Creator"] + variable_names
    sheet_scope.each do |sheet|
      row = [sheet.name,
              sheet.description,
              sheet.study_date.blank? ? '' : sheet.study_date.strftime("%m-%d-%Y"),
              sheet.project.name,
              sheet.subject.site.name,
              sheet.subject.name,
              sheet.project.acrostic_enabled? ? sheet.subject.acrostic : nil,
              sheet.subject.status,
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

  [export_file.split('/').last, export_file]
end

def generate_csv_grids(export, sheet_scope, filename, raw_data)
  export_file = File.join('tmp', 'files', 'exports', "#{filename}_grids_#{raw_data ? 'raw' : 'labeled'}.csv")

  CSV.open(export_file, "wb") do |csv|
    variable_ids = Design.where(id: sheet_scope.pluck(:design_id)).collect(&:variable_ids).flatten.uniq
    # variable_ids = SheetVariable.where(sheet_id: sheet_scope.pluck(:id)).collect(&:variable_id)
    grid_group_variables = Variable.current.where(variable_type: 'grid', id: variable_ids)

    row = ["", "", "", "", "", "", "", "", ""]

    grid_group_variables.each do |variable|
      variable.grid_variables.each do |grid_variable_hash|
        grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
        row << variable.name if grid_variable
      end
    end

    csv << row

    row = ["Name", "Description", "Sheet Date", "Project", "Site", "Subject", "Acrostic", "Status", "Creator"]

    grid_group_variables.each do |variable|
      variable.grid_variables.each do |grid_variable_hash|
        grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
        row << grid_variable.name if grid_variable
      end
    end

    csv << row

    sheet_scope.each do |s|
      (0..s.max_grids_position).each do |position|
        row = [s.name, s.description, (s.study_date.blank? ? '' : s.study_date.strftime("%m-%d-%Y")), s.project.name, s.subject.site.name, s.subject.name, (s.project.acrostic_enabled? ? s.subject.acrostic : nil), s.subject.status, s.user.name]

        grid_group_variables.each do |variable|
          variable.grid_variables.each do |grid_variable_hash|
            sheet_variable = s.sheet_variables.find_by_variable_id(variable.id)
            result_hash = (sheet_variable ? sheet_variable.response_hash(position, grid_variable_hash[:variable_id]) : {})
            cell = if raw_data
              result_hash.kind_of?(Array) ? result_hash.collect{|h| h[:value]}.join(',') : result_hash[:value]
            else
              result_hash.kind_of?(Array) ? result_hash.collect{|h| "#{h[:value]}: #{h[:name]}"}.join(', ') : result_hash[:name]
            end
            row << cell
          end
        end

        csv << row
      end
    end
  end

  [export_file.split('/').last, export_file]
end

def generate_pdf(export, sheet_scope, filename)
  pdf_file = Sheet.latex_file_location(sheet_scope, export.user)

  [pdf_file.split('/').last, pdf_file]
end


def generated_data_dictionary(export, sheet_scope, filename)

  design_scope = Design.where(id: sheet_scope.pluck(:design_id))

  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet::Workbook.new

  worksheet = book.create_worksheet name: "Design Info"
  # Contains general information
  # Name, Description, Email Subject Template, Email Body Template, Study Date Name
  current_row = 0
  worksheet.row(current_row).replace ["Name", "Description", "Email Subject Template", "Email Body Template", "Study Date Name"]

  design_scope.each do |d|
    current_row += 1
    worksheet.row(current_row).push d.name, d.description, d.email_subject_template, d.email_template, d.study_date_name
  end

  # Design Layout
  worksheet = book.create_worksheet name: "Design Layout"
  current_row = 0
  worksheet.row(current_row).push 'Design Name', 'Name', 'Display Name', 'Branching Logic', 'Description', 'Break Before'

  design_scope.each do |d|
    d.options.each do |option|
      current_row += 1
      row = []
      if option[:variable_id].blank?
        worksheet.row(current_row).push d.name,
          option[:section_id],
          option[:section_name],
          option[:branching_logic],
          option[:section_description], # Variable Description
          option[:break_before]
      elsif variable = Variable.current.find_by_id(option[:variable_id])
        worksheet.row(current_row).push d.name,
          variable.name,
          variable.display_name,
          option[:branching_logic],
          variable.description, # Variable Description
          option[:break_before]
      end
    end
  end

  # Variables
  worksheet = book.create_worksheet name: "Variables"
  current_row = 0
  worksheet.row(current_row).push 'Design Name', 'Variable Name', 'Variable Display Name', 'Variable Header', 'Variable Description',
    'Variable Type', 'Hard Min', 'Soft Min', 'Soft Max', 'Hard Max',
    'Calculation', 'Prepend', 'Units', 'Append',
    'Format', 'Multiple Rows', 'Autocomplete Values', 'Show Current Button',
    'Display Name Visibility', 'Alignment', 'Default Row Number', 'Scale Type', 'Domain Name'

  design_scope.each do |d|
    d.options_with_grid_sub_variables.each do |option|
      current_row += 1
      row = []
      if option[:variable_id].blank?
        worksheet.row(current_row).push d.name,
          option[:section_id],
          option[:section_name],
          nil, # Variable Header
          option[:section_description], # Variable Description
          'section',
          nil, # Hard Min
          nil, # Soft Min
          nil, # Soft Max
          nil, # Hard Max
          nil, # Calculation
          nil, # Variable Prepend
          nil, # Variable Units
          nil, # Variable Append
          nil, # Format
          nil, # Multiple Rows
          nil, # Autocomplete Values
          nil, # Show Current Button
          nil, # Display Name Visiblity
          nil, # Alignment
          nil, # Default Row Number
          nil, # Scale Type
          nil # Domain Name
      elsif variable = Variable.current.find_by_id(option[:variable_id])
        worksheet.row(current_row).push d.name,
          variable.name,
          variable.display_name,
          variable.header, # Variable Header
          variable.description, # Variable Description
          variable.variable_type,
          (variable.variable_type == 'date' ? variable.date_hard_minimum : variable.hard_minimum), # Hard Min
          (variable.variable_type == 'date' ? variable.date_soft_minimum : variable.soft_minimum), # Soft Min
          (variable.variable_type == 'date' ? variable.date_soft_maximum : variable.soft_maximum), # Soft Max
          (variable.variable_type == 'date' ? variable.date_hard_maximum : variable.hard_maximum), # Hard Max
          variable.calculation, # Calculation
          variable.prepend, # Variable Prepend
          variable.units, # Variable Units
          variable.append, # Variable Append
          variable.format, # Format
          variable.multiple_rows, # Multiple Rows
          variable.autocomplete_values, # Autocomplete Values
          variable.show_current_button, # Show Current Button
          variable.display_name_visibility, # Display Name Visiblity
          variable.alignment, # Alignment
          variable.default_row_number, # Default Row Number
          (variable.variable_type == 'scale' ? variable.scale_type : ''), # Scale Type
          (variable.domain ? variable.domain.name : '') # Domain Name
      end
    end
  end

  # Variable Options
  worksheet = book.create_worksheet name: "Variable Options"
  current_row = 0

  worksheet.row(current_row).push 'Variable/Domain Name', 'Description',
    'Option Name', 'Option Value', 'Missing Code?', 'Option Color', 'Option Description'

  objects = []

  design_scope.each do |d|
    d.options_with_grid_sub_variables.each do |option|
      if variable = Variable.current.find_by_id(option[:variable_id])
        if variable.variable_type == 'scale' and variable.domain
          objects << variable.domain
        else
          objects << variable
        end
      end
    end
  end

  objects.uniq.each do |object|
    object.options.each do |opt|
      current_row += 1
      worksheet.row(current_row).push object.name,
        object.description,
        opt[:name],
        opt[:value],
        opt[:missing_code],
        opt[:color],
        opt[:description]
    end
  end

  export_file = File.join('tmp', 'files', 'exports', "#{export.name.gsub(/[^a-zA-Z0-9_-]/, '_')} #{export.created_at.strftime("%I%M%P")}_data_dictionaries.xls")

  book.write(export_file)
  [export_file.split('/').last, export_file]
end
