desc "Generate file for design exports"
task design_export: :environment do
  export = Export.find_by_id(ENV["EXPORT_ID"])
  design_scope = Design.current.where(id: ENV["DESIGN_IDS"].to_s.split(','))

  begin
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

    design_scope.each do |d|
      d.options_with_grid_sub_variables.each do |option|
        row = []
        if variable = Variable.current.find_by_id(option[:variable_id])
          if variable.variable_type == 'scale' and variable.domain
            object = variable.domain
          else
            object = variable
          end
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
      end
    end


    filename = File.join('tmp', 'files', 'exports', "#{export.name.gsub(/[^a-zA-Z0-9_-]/, '_')} #{export.created_at.strftime("%I%M%P")}.xls")

    book.write(filename)

    export.update_attributes file: File.open(filename), file_created_at: Time.now, status: 'ready'

    export.notify_user!
  rescue => e
    export.update_attributes status: 'failed', details: e.message
    Rails.logger.debug "Error: #{e}"
  end
end
