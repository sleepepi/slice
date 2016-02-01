# frozen_string_literal: true

# Generates a full export of sheets to a chosen format for a project
class Export < ActiveRecord::Base
  mount_uploader :file, ZipUploader

  STATUS = %w(ready pending failed).collect { |i| [i, i] }

  # Concerns
  include Searchable, Deletable, GridExport, SheetExport, Forkable

  # Model Validation
  validates :name, :user_id, :project_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods

  def self.searchable_attributes
    %w(name)
  end

  def zip_file_path
    File.join(CarrierWave::Uploader::Base.root, file.url)
  end

  def notify_user!
    UserMailer.export_ready(self).deliver_later if EMAILS_ENABLED
  end

  def generate_export_in_background!
    fork_process(:generate_export!)
  end

  def generate_export!
    sheet_scope = project.sheets
    variables_count = all_design_variables_using_design_ids(sheet_scope.select(:design_id)).count
    update sheet_ids_count: sheet_scope.count, variables_count: variables_count
    calculate_total_steps
    finalize_export!(generate_zip_file(sheet_scope))
  rescue => e
    export_failed(e.message.to_s + e.backtrace.to_s)
  end

  private

  def finalize_export!(export_file)
    if export_file
      export_succeeded(export_file)
    else
      export_failed(failure_details)
    end
  end

  def failure_details
    if include_files?
      'No sheets have had files uploaded. Zip file not created.'
    else
      'No files were created. At least one file type needs to be selected for exports.'
    end
  end

  def export_succeeded(export_file)
    update status: 'ready', file: File.open(export_file), file_created_at: Time.zone.now, steps_completed: total_steps
    notify_user!
  end

  def export_failed(details)
    update status: 'failed', details: details
  end

  def generate_all_files(sheet_scope, filename)
    all_files = [] # If numerous files are created then they need to be zipped!
    all_files << generate_csv_sheets(sheet_scope, filename, false, 'csv') if include_csv_labeled?
    all_files << generate_csv_grids(sheet_scope, filename, false, 'csv')  if include_csv_labeled?
    all_files << generate_csv_sheets(sheet_scope, filename, true, 'csv')  if include_csv_raw?
    all_files << generate_csv_grids(sheet_scope, filename, true, 'csv')   if include_csv_raw?
    all_files << generate_readme('csv')                                   if include_csv_labeled? || include_csv_raw?
    all_files += generate_pdf(sheet_scope)                                if include_pdf?
    all_files += generate_data_dictionary(sheet_scope)                    if include_data_dictionary?
    all_files += generate_sas(sheet_scope, filename)                      if include_sas?
    all_files << generate_csv_sheets(sheet_scope, filename, true, 'sas')  if include_sas?
    all_files << generate_csv_grids(sheet_scope, filename, true, 'sas')   if include_sas?
    all_files += generate_r(sheet_scope, filename)                      if include_r?
    all_files << generate_csv_sheets(sheet_scope, filename, true, 'r')  if include_r?
    all_files << generate_csv_grids(sheet_scope, filename, true, 'r')   if include_r?

    if include_files?
      sheet_scope.each do |sheet|
        all_files += sheet.files
        update_steps(1)
      end
      all_files << generate_readme('files')
    end

    all_files
  end

  # Zip multiple files, or zip one file if it's part of the sheet uploaded
  # files, always zip folder
  def generate_zip_file(sheet_scope)
    filename = "#{name.gsub(/[^a-zA-Z0-9_-]/, '_')}_#{created_at.strftime('%H%M')}"
    all_files = generate_all_files(sheet_scope, filename)

    return if all_files.empty?

    # Create a zip file
    zipfile_name = File.join('tmp', 'files', 'exports', "#{filename} #{Digest::SHA1.hexdigest(Time.zone.now.usec.to_s)[0..8]}.zip")
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      all_files.uniq.each do |location, input_file|
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(location, input_file) if File.exist?(input_file) && File.size(input_file) > 0
      end
    end
    zipfile_name
  end

  def calculate_total_steps
    all_exports = [:include_csv_labeled, :include_csv_raw, :include_sas, :include_pdf, :include_data_dictionary, :include_r, :include_files]
    steps = all_exports.collect { |export| steps_for(export) }.sum
    update_column :total_steps, steps
  end

  def steps_for(attribute)
    double_step_attributes = [:include_csv_labeled, :include_csv_raw, :include_sas]
    if double_step_attributes.include?(attribute)
      steps_for_variables_and_grids(send(attribute))
    else
      steps_for_one_run(send(attribute))
    end
  end

  def steps_for_one_run(included)
    included ? sheet_ids_count : 0
  end

  def steps_for_variables_and_grids(included)
    included ? variables_count : 0
  end

  def update_steps(amount)
    update_column :steps_completed, steps_completed + amount
  end

  def generate_pdf(sheet_scope)
    pdf_file = Sheet.latex_file_location(sheet_scope, user)
    update_steps(sheet_ids_count)
    [["PDF/#{pdf_file.split('/').last}", pdf_file], generate_readme('pdf')]
  end

  def generate_data_dictionary(sheet_scope)
    design_scope = Design.where(id: sheet_scope.pluck(:design_id)).order('name')

    designs_csv = File.join('tmp', 'files', 'exports', "#{name.gsub(/[^a-zA-Z0-9_-]/, '_')} #{created_at.strftime('%I%M%P')}_designs.csv")

    CSV.open(designs_csv, 'wb') do |csv|
      csv << ['Design Name', 'Name', 'Display Name', 'Branching Logic', 'Description']

      design_scope.each do |d|
        d.design_options.includes(:section, :variable).each do |design_option|
          if section = design_option.section
            csv << [d.name, section.to_slug, section.name, design_option.branching_logic, section.description]
          elsif variable = design_option.variable
            csv << [d.name, variable.name, variable.display_name, design_option.branching_logic, variable.description]
          end
        end
      end
    end

    variables_csv = File.join('tmp', 'files', 'exports', "#{name.gsub(/[^a-zA-Z0-9_-]/, '_')} #{created_at.strftime('%I%M%P')}_variables.csv")

    CSV.open(variables_csv, 'wb') do |csv|
      csv << ['Design Name', 'Variable Name', 'Variable Display Name', 'Variable Description',
              'Variable Type', 'Hard Min', 'Soft Min', 'Soft Max', 'Hard Max', 'Calculation', 'Prepend', 'Units',
              'Append', 'Format', 'Multiple Rows', 'Autocomplete Values', 'Show Current Button',
              'Display Name Visibility', 'Alignment', 'Default Row Number', 'Domain Name']
      design_scope.each do |d|
        d.options_with_grid_sub_variables.each do |design_option|
          section = design_option.section
          variable = design_option.variable
          if section
            csv << [d.name,
                    section.to_slug,
                    section.name,
                    section.description, # Variable Description
                    (section.sub_section? ? 'subsection' : 'section'),
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
                    nil] # Domain Name
          elsif variable
            csv << [d.name,
                    variable.name,
                    variable.display_name,
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
                    (variable.domain ? variable.domain.name : '')] # Domain Name
          end
        end
      end
    end

    csv_name = "#{name.gsub(/[^a-zA-Z0-9_-]/, '_')} #{created_at.strftime('%I%M%P')}_domains.csv"
    domains_csv = File.join('tmp', 'files', 'exports', csv_name)

    CSV.open(domains_csv, 'wb') do |csv|
      csv << ['Domain Name', 'Description', 'Option Name', 'Option Value', 'Missing Code', 'Option Description']

      objects = []

      design_scope.each do |d|
        d.options_with_grid_sub_variables.each do |design_option|
          if variable = design_option.variable and variable.domain
            objects << variable.domain
          end
        end
      end

      objects.uniq.each do |object|
        object.options.each do |opt|
          csv << [object.name, object.description, opt[:name], opt[:value], opt[:missing_code], opt[:description]]
        end
      end
    end

    update_steps(sheet_ids_count)
    [["DD/#{designs_csv.split('/').last}", designs_csv], ["DD/#{variables_csv.split('/').last}", variables_csv], ["DD/#{domains_csv.split('/').last}", domains_csv], generate_readme('dd', sheet_scope)]
  end

  def generate_statistic_export_from_erb(sheet_scope, filename, language)
    @export_formatter = ExportFormatter.new(sheet_scope, filename)

    erb_file = File.join('app', 'views', 'exports', "export.#{language}.erb")
    export_file = File.join('tmp', 'files', 'exports', "#{filename}_#{language}.#{language}")

    File.open(export_file, 'w') do |file|
      file.syswrite(ERB.new(File.read(erb_file)).result(binding))
    end

    [["#{language.upcase}/#{export_file.split('/').last}", export_file], generate_readme(language)]
  end

  def generate_r(sheet_scope, filename)
    generate_statistic_export_from_erb(sheet_scope, filename, 'r')
  end

  def generate_sas(sheet_scope, filename)
    generate_statistic_export_from_erb(sheet_scope, filename, 'sas')
  end

  def generate_readme(language, sheet_scope = Sheet.none)
    erb_file = File.join('test', 'support', 'exports', language, 'README.erb')
    readme = File.join('tmp', 'files', 'exports', "README_#{language}_#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}.txt")

    File.open(readme, 'w') do |file|
      file.syswrite(ERB.new(File.read(erb_file)).result(binding))
    end

    ["#{language.upcase}/README.txt", readme]
  end

  def all_design_variables_without_grids(sheet_scope)
    Design.where(id: sheet_scope.pluck(:design_id)).order(:id).collect(&:variables).flatten.uniq.select { |v| v.variable_type != 'grid' }
  end

  def all_design_variables_using_design_ids(design_ids)
    Variable.current.joins(:design_options)
            .where(design_options: { design_id: design_ids })
            .order('design_options.design_id', 'design_options.position')
  end
end
