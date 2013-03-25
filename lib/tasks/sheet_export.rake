require 'rubygems'
require 'zip/zip'

desc "Generate file for sheet exports"
task sheet_export: :environment do
  export = Export.find_by_id(ENV["EXPORT_ID"])
  sheet_scope = Sheet.current.where(id: ENV["SHEET_IDS"].to_s.split(',')).joins(:design).order('designs.name, sheets.created_at')

  begin
    filename = "#{export.name.gsub(/[^a-zA-Z0-9_-]/, '_')} #{export.created_at.strftime("%I%M%P")}"

    all_files = [] # If numerous files are created then they need to be zipped!

    all_files << generate_xls(export, sheet_scope, filename)                if export.include_xls?
    all_files << generate_csv_sheets(export, sheet_scope, filename, false)  if export.include_csv_labeled?
    all_files << generate_csv_grids(export, sheet_scope, filename, false)   if export.include_csv_labeled?
    all_files << generate_csv_sheets(export, sheet_scope, filename, true)   if export.include_csv_raw? or export.include_sas?
    all_files << generate_csv_grids(export, sheet_scope, filename, true)    if export.include_csv_raw? or export.include_sas?
    all_files << generate_pdf(export, sheet_scope, filename)                if export.include_pdf?
    all_files << generate_data_dictionary(export, sheet_scope, filename)    if export.include_data_dictionary?
    all_files << generate_sas(export, sheet_scope, filename)                if export.include_sas?
    sheet_scope.each{ |sheet| all_files += sheet.files }                    if export.include_files?

    # Zip multiple files, or zip one file if it's part of the sheet uploaded files
    export_file = if all_files.size > 1 or (export.include_files? and all_files.size == 1)
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
    worksheet.row(current_row).replace ["Name", "Description", "Sheet Creation Date", "Project", "Site", "Subject", "Acrostic", "Status", "Creator"] + variable_names.collect{|v| v[0]}
    sheet_scope.each do |s|
      current_row += 1
      worksheet.row(current_row).push s.name, s.description, s.created_at.strftime("%Y-%m-%d"), s.project.name, s.subject.site.name, s.subject.name, (s.project.acrostic_enabled? ? s.subject.acrostic : nil), s.subject.status, s.user.name
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
    worksheet.row(current_row).replace ["Name", "Description", "Sheet Creation Date", "Project", "Site", "Subject", "Acrostic", "Status", "Creator"]

    grid_group_variables.each do |variable|
      variable.grid_variables.each do |grid_variable_hash|
        grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
        worksheet.row(current_row).push grid_variable.name if grid_variable
      end
    end

    sheet_scope.each do |s|
      (0..s.max_grids_position).each do |position|
        current_row += 1
        worksheet.row(current_row).push s.name, s.description, s.created_at.strftime("%Y-%m-%d"), s.project.name, s.subject.site.name, s.subject.name, (s.project.acrostic_enabled? ? s.subject.acrostic : nil), s.subject.status, s.user.name

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
    csv << ["Name", "Description", "Sheet Creation Date", "Project", "Site", "Subject", "Acrostic", "Status", "Creator"] + variable_names
    sheet_scope.each do |sheet|
      row = [sheet.name,
              sheet.description,
              sheet.created_at.strftime("%Y-%m-%d"),
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
    grid_group_variables = Variable.current.where(variable_type: 'grid', id: variable_ids)

    row = ["", "", "", "", "", "", "", "", ""]

    grid_group_variables.each do |variable|
      variable.grid_variables.each do |grid_variable_hash|
        grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
        row << variable.name if grid_variable
      end
    end

    csv << row

    row = ["Name", "Description", "Sheet Creation Date", "Project", "Site", "Subject", "Acrostic", "Status", "Creator"]

    grid_group_variables.each do |variable|
      variable.grid_variables.each do |grid_variable_hash|
        grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
        row << grid_variable.name if grid_variable
      end
    end

    csv << row

    sheet_scope.each do |s|
      (0..s.max_grids_position).each do |position|
        row = [s.name, s.description, s.created_at.strftime("%Y-%m-%d"), s.project.name, s.subject.site.name, s.subject.name, (s.project.acrostic_enabled? ? s.subject.acrostic : nil), s.subject.status, s.user.name]

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


def generate_data_dictionary(export, sheet_scope, filename)

  design_scope = Design.where(id: sheet_scope.pluck(:design_id))

  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet::Workbook.new

  worksheet = book.create_worksheet name: "Design Info"
  # Contains general information
  # Name, Description, Email Subject Template, Email Body Template
  current_row = 0
  worksheet.row(current_row).replace ["Name", "Description", "Email Subject Template", "Email Body Template"]

  design_scope.each do |d|
    current_row += 1
    worksheet.row(current_row).push d.name, d.description, d.email_subject_template, d.email_template
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

  worksheet.row(current_row).push 'Domain Name', 'Description',
    'Option Name', 'Option Value', 'Missing Code?', 'Option Color', 'Option Description'

  objects = []

  design_scope.each do |d|
    d.options_with_grid_sub_variables.each do |option|
      if variable = Variable.current.find_by_id(option[:variable_id])
        objects << variable.domain if variable.domain
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

def generate_sas(export, sheet_scope, filename)
  export_file = File.join('tmp', 'files', 'exports', "#{filename}_sas.sas")
  design_scope = Design.where(id: sheet_scope.pluck(:design_id))
  variables = Design.where(id: sheet_scope.pluck(:design_id)).collect(&:variables).flatten.uniq
  domains = Domain.where(id: variables.collect{|v| v.domain_id}).order('name')

  variable_ids = Design.where(id: sheet_scope.pluck(:design_id)).collect(&:variable_ids).flatten.uniq
  grid_group_variables = Variable.current.where(variable_type: 'grid', id: variable_ids)
  grid_variables = []
  grid_group_variables.each do |variable|
    variable.grid_variables.each do |grid_variable_hash|
      grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
      grid_variables << grid_variable if grid_variable
    end
  end
  grid_domains = Domain.where(id: grid_variables.collect{|v| v.domain_id}).order('name')


  File.open(export_file, 'w') do |f|
    f.write sas_header(filename)
    f.write sas_step1(variables, false)
    f.write sas_step2(variables, false)
    f.write sas_step3(domains, false)
    f.write sas_step4(variables, false)
    f.write sas_step5(false)

    # For Grids
    f.write sas_step1(grid_variables, true)
    f.write sas_step2(grid_variables, true)
    f.write sas_step3(grid_domains, true)
    f.write sas_step4(grid_variables, true)
    f.write sas_step5(true)
  end

  [export_file.split('/').last, export_file]
end

def sas_header(filename)
  <<-eos
/* Generated by Slice v#{Slice::VERSION::STRING} */
/*           on #{Time.now.strftime("%a, %B %d, %Y at %-l:%M%p")} */

/* YOU WILL NEED TO MODIFY IMPORT FOLDER */
/* TO POINT TO THE LOCATION WHERE YOU    */
/* DOWNLOADED THE CSV AND SAS FILES      */

%let import_folder      = C: ;
%let import_file        = #{filename}_raw ;
%let import_file_grids  = #{filename}_grids_raw ;

  eos
end

def sas_step1(variables, use_grids)
  <<-eos
/* Replace carriage returns inside delimiters */
data _null_;
  infile "&import_folder.\\&import_file#{'_grids' if use_grids}..csv" recfm=n;
  file "&import_folder.\\&import_file#{'_grids' if use_grids}._sas.csv" recfm=n;
  input a $char1.;
  retain open 0;
  if a='"' then open=not open;
  if (a='0A'x or a='0D'x) and open then put '00'x @;
  else put a $char1. @;
run;

/* Step 1: Import data into slice work library */

data slice#{'_grids' if use_grids};
  infile "&import_folder.\\&import_file#{'_grids' if use_grids}._sas.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=#{use_grids ? 3 : 2} ;

  /* Design and Subject Variables */
  informat name                 $500.     ;   * Design name ;
  informat description          $5000.    ;   * Design description ;
  informat sheet_creation_date  yymmdd10. ;   * Sheet creation date ;
  informat project              $500.     ;   * Project name ;
  informat site                 $500.     ;   * Subject site name ;
  informat subject              $100.     ;   * Subject code ;
  informat acrostic             $100.     ;   * Subject acrostic ;
  informat status               $10.      ;   * Subject status ;
  informat creator              $100.     ;   * Sheet creator ;

  /* Sheet Variables */
#{variables.collect{|v| "  informat #{v.name} #{v.sas_informat}. ;" }.join("\n")}

  /* Design and Subject Variables */
  format name                   $500.     ;
  format description            $500.     ;
  format sheet_creation_date    yymmdd10. ;
  format project                $500.     ;
  format site                   $500.     ;
  format subject                $100.     ;
  format acrostic               $100.     ;
  format status                 $10.      ;
  format creator                $100.     ;

  /* Sheet Variables */
#{variables.collect{|v| "  format #{v.name} #{v.sas_format}. ;" }.join("\n")}

  /* Define Column Names */

  input
    name
    description
    sheet_creation_date
    project
    site
    subject
    acrostic
    status
    creator
#{variables.collect{|v| "    #{v.name}"}.join("\n")}
  ;
run;

  eos
end

def sas_step2(variables, use_grids)
  <<-eos
/* Step 2: Apply labels to variables using slice display names */

data slice#{'_grids' if use_grids};
  set slice#{'_grids' if use_grids};

  /* Design and Subject Variables */
  label name='Design Name';
  label description='Design Description';
  label sheet_creation_date='Sheet Creation Date';
  label project='Project';
  label site='Site';
  label subject='Subject ID';
  label acrostic='Subject Acrostic';
  label status='Subject Status';
  label creator='Sheet Creator';

  /* Sheet Variables */
#{variables.collect{|v| "  label #{v.name}='#{v.display_name.gsub("'", "\\\\'")}';" }.join("\n")}
run;

  eos
end

def sas_step3(domains, use_grids)
  <<-eos
/* Step 3: Create formats for slice domain options */

proc format;
#{domains.collect{ |d| "  value #{d.name}f\n#{d.options.collect{|o| "    #{o[:value]}='#{o[:value]}: #{o[:name].gsub("'", "\\\\'")}'"}.join("\n")}\n  ;" }.join("\n")}
run;

  eos
end

def sas_step4(variables, use_grids)
  <<-eos
/* Step 4: Apply format to all of the variables */

data slice#{'_grids' if use_grids};
  set slice#{'_grids' if use_grids};

#{variables.collect{|v| v.domain ? "  format #{v.name} #{v.domain.name}f. ;" : nil }.compact.join("\n")}
run;

  eos
end

def sas_step5(use_grids)
  <<-eos
/* Step 5: Output summary of dataset */

proc contents data=slice#{'_grids' if use_grids};
run;
quit;

  eos
end
