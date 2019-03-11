# frozen_string_literal: true

# Generates a full export of sheets to a chosen format for a project.
class Export < ApplicationRecord
  # Uploaders
  mount_uploader :file, ZipUploader

  # Constants
  STATUS = %w(ready pending failed).collect { |i| [i, i] }

  # Concerns
  include Deletable
  include Forkable
  include GridExport
  include Searchable
  include SheetExport

  # Validations
  validates :name, presence: true

  # Relationships
  belongs_to :user
  belongs_to :project
  has_many :notifications

  # Methods

  def self.searchable_attributes
    %w(name)
  end

  def extension
    file.file.present? ? file.file.extension.to_s.downcase : ""
  end

  def create_notification
    notification = user.notifications.where(project_id: project_id, export_id: id).first_or_create
    notification.mark_as_unread!
  end

  def generate_export_in_background!
    fork_process(:generate_export!)
  end

  def generate_export!
    sheet_ids = filter_sheets.pluck(:id)
    # Don't export Adverse Event reviewer sheets (only include reporter, admin, and principal reviewer sheets).
    sheet_ids -= project.ae_sheets.where(role: "reviewer").pluck(:sheet_id)
    # Freeze the sheet scope to avoid data shifting during export.
    sheet_scope = Sheet.where(id: sheet_ids)
    all_variables = all_design_variables_using_design_ids(sheet_scope.select(:design_id))
    variables_count = all_variables.uniq.count
    grid_variables_count = all_variables.where(variable_type: "grid").uniq.count
    update sheet_ids_count: sheet_ids.size, variables_count: variables_count, grid_variables_count: grid_variables_count
    calculate_total_steps
    generate_zip_file!(sheet_scope)
  rescue => e
    export_failed(e.message.to_s + e.backtrace.to_s)
  end

  def filter_sheets
    scope = user.all_viewable_sheets.where(project: project)
    tokens = Search.pull_tokens(filters)
    tokens.reject { |t| t.key == "search" }.each do |token|
      scope = \
        case token.key
        when "created"
          scope_by_date(scope, token)
        else
          scope_by_variable(scope, token)
        end
    end
    terms = tokens.select { |t| t.key == "search" }.collect(&:value)
    scope.search(terms.join(" "))
  end

  def scope_by_date(scope, token)
    date = Date.strptime(token.value, "%Y-%m-%d")
    case token.operator
    when "<"
      scope.sheet_before(date - 1.day)
    when ">"
      scope.sheet_after(date + 1.day)
    when "<="
      scope.sheet_before(date)
    when ">="
      scope.sheet_after(date)
    else
      scope.sheet_before(date).sheet_after(date)
    end
  rescue
    scope
  end

  def scope_by_variable(scope, token)
    Search.run_sheets(project, user, scope, token)
  end

  def destroy
    super
    notifications.destroy_all
  end

  private

  def failure_details
    if include_files?
      "No sheets have had files uploaded. Zip file not created."
    else
      "No files were created. At least one file type needs to be selected for exports."
    end
  end

  def export_succeeded(export_file)
    update(
      status: "ready",
      file: File.open(export_file),
      file_created_at: Time.zone.now,
      file_size: File.size(export_file),
      steps_completed: total_steps
    )
    create_notification
  end

  def export_failed(details)
    update status: "failed", details: details
    create_notification
  end

  def generate_all_files(sheet_scope, temp_dir, filename)
    all_files = [] # If numerous files are created then they need to be zipped!
    all_files << generate_csv_sheets(sheet_scope, temp_dir, filename, false, "csvs") if include_csv_labeled?
    all_files << generate_csv_grids(sheet_scope, temp_dir, filename, false, "csvs")  if include_csv_labeled? && include_grids?
    all_files << generate_csv_sheets(sheet_scope, temp_dir, filename, true, "csvs")  if include_csv_raw?
    all_files << generate_csv_grids(sheet_scope, temp_dir, filename, true, "csvs")   if include_csv_raw? && include_grids?
    all_files << generate_readme(temp_dir, "csvs")                                   if include_csv_labeled? || include_csv_raw?
    all_files += generate_pdf(sheet_scope, temp_dir)                                 if include_pdf?
    all_files += generate_data_dictionary(sheet_scope, temp_dir)                     if include_data_dictionary?
    all_files += generate_sas(sheet_scope, temp_dir, filename)                       if include_sas?
    all_files << generate_csv_sheets(sheet_scope, temp_dir, filename, true, "sas")   if include_sas?
    all_files << generate_csv_grids(sheet_scope, temp_dir, filename, true, "sas")    if include_sas? && include_grids?
    all_files += generate_r(sheet_scope, temp_dir, filename)                         if include_r?
    all_files << generate_csv_sheets(sheet_scope, temp_dir, filename, true, "r")     if include_r?
    all_files << generate_csv_grids(sheet_scope, temp_dir, filename, true, "r")      if include_r? && include_grids?
    all_files << generate_csv_adverse_events(temp_dir, filename)                     if include_adverse_events?
    all_files << generate_csv_adverse_events_master_list(temp_dir, filename)         if include_adverse_events?
    all_files << generate_csv_randomizations(temp_dir, filename)                     if include_randomizations?
    all_files << generate_medications(temp_dir, filename)                            if include_medications?

    if include_files?
      sheet_scope.each do |sheet|
        all_files += sheet.files
        update_steps(1)
      end
      all_files << generate_readme(temp_dir, "files")
    end

    all_files
  end

  # Zip multiple files, or zip one file if it's part of the sheet uploaded
  # files, always zip folder
  def generate_zip_file!(sheet_scope)
    temp_dir = Dir.mktmpdir


    filename = "#{name.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{created_at.strftime("%H%M")}"
    all_files = generate_all_files(sheet_scope, temp_dir, filename)

    return if all_files.empty?

    # Create a zip file
    zipfile_name = File.join(temp_dir, "#{filename}.zip")
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
      all_files.uniq.each do |location, input_file|
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(location, input_file) if File.exist?(input_file) && File.size(input_file) > 0
      end
    end
    zipfile_name

    if File.exist?(zipfile_name)
      export_succeeded(zipfile_name)
    else
      export_failed(failure_details)
    end
  ensure
    # Remove the directory.
    FileUtils.remove_entry temp_dir
  end

  def calculate_total_steps
    all_exports = [:include_csv_labeled, :include_csv_raw, :include_sas, :include_pdf, :include_data_dictionary, :include_r, :include_files, :include_adverse_events]
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

  def include_grids?
    grid_variables_count > 0
  end

  def generate_pdf(sheet_scope, temp_dir)
    # pdf_file = Sheet.latex_file_location(sheet_scope, user)
    # [["pdf/#{pdf_file.split("/").last}", pdf_file], generate_readme(temp_dir, "pdf")]
    update_steps(sheet_ids_count)
    [generate_readme(temp_dir, "pdf")]
  end

  def generate_data_dictionary(sheet_scope, temp_dir)
    design_scope = \
      if filters.present?
        project.designs.where(id: sheet_scope.select(:design_id)).order(:name)
      else
        project.designs.order(:name)
      end
    designs_csv = File.join(temp_dir, "#{name.gsub(/[^a-zA-Z0-9_-]/, "_")}_designs.csv")

    CSV.open(designs_csv, "wb") do |csv|
      csv << ["Design Name", "Name", "Display Name", "Branching Logic", "Description", "Field Note"]

      design_scope.each do |d|
        d.design_options.includes(:section, :variable).each do |design_option|
          section = design_option.section
          variable = design_option.variable
          if section
            csv << [d.name, section.to_slug, section.name, design_option.branching_logic, section.description, nil]
          elsif variable
            variable.csv_columns_and_names.each do |variable_name, variable_display_name|
              csv << [
                d.name, variable_name, variable_display_name,
                design_option.branching_logic, variable.description,
                variable.field_note
              ]
            end
          end
        end
      end
    end

    variables_csv = File.join(temp_dir, "#{name.gsub(/[^a-zA-Z0-9_-]/, "_")}_variables.csv")

    CSV.open(variables_csv, "wb") do |csv|
      csv << [
        "Design Name", "Variable Name", "Variable Display Name", "Variable Description", "Field Note",
        "Variable Type", "Hard Min", "Soft Min", "Soft Max", "Hard Max", "Calculation", "Prepend", "Units",
        "Append", "Calculated Format", "Date Format", "Time Duration Format", "Time of Day Format", "Multiple Rows",
        "Autocomplete Values", "Show Current Button", "Display Layout", "Alignment", "Default Row Number",
        "Domain Name", "Required on Form?"
      ]
      design_scope.each do |d|
        d.options_with_grid_sub_variables.each do |design_option|
          section = design_option.section
          variable = design_option.variable
          if section
            csv << [d.name,
                    section.to_slug,
                    section.name,
                    section.description, # Variable Description
                    nil, # Field Note
                    section.level_name.downcase,
                    nil, # Hard Min
                    nil, # Soft Min
                    nil, # Soft Max
                    nil, # Hard Max
                    nil, # Calculation
                    nil, # Variable Prepend
                    nil, # Variable Units
                    nil, # Variable Append
                    nil, # Format
                    nil, # Date Format
                    nil, # Time Duration Format
                    nil, # Time of Day Format
                    nil, # Multiple Rows
                    nil, # Autocomplete Values
                    nil, # Show Current Button
                    nil, # Display Name Visiblity
                    nil, # Alignment
                    nil, # Default Row Number
                    nil, # Domain Name
                    nil] # Required on Form?
          elsif variable
            variable.csv_columns_and_names.each do |variable_name, variable_display_name|
              csv << [d.name,
                      variable_name,
                      variable_display_name,
                      variable.description,
                      variable.field_note,
                      variable.export_variable_type,
                      (variable.variable_type == "date" ? variable.date_hard_minimum : variable.hard_minimum),
                      (variable.variable_type == "date" ? variable.date_soft_minimum : variable.soft_minimum),
                      (variable.variable_type == "date" ? variable.date_soft_maximum : variable.soft_maximum),
                      (variable.variable_type == "date" ? variable.date_hard_maximum : variable.hard_maximum),
                      variable.readable_calculation,
                      variable.prepend,
                      variable.export_units,
                      variable.append,
                      variable.calculated_format,
                      (variable.variable_type == "date" ? variable.date_format : nil),
                      (variable.variable_type == "time_duration" ? variable.time_duration_format : nil),
                      (variable.variable_type == "time_of_day" ? variable.time_of_day_format : nil),
                      variable.multiple_rows,
                      variable.autocomplete_values,
                      variable.show_current_button,
                      variable.display_layout,
                      variable.alignment,
                      variable.default_row_number,
                      (variable.domain ? variable.domain.name : ""),
                      design_option.requirement_string]
            end
          end
        end
      end
    end
    csv_name = "#{name.gsub(/[^a-zA-Z0-9_-]/, "_")}_domains.csv"
    domains_csv = File.join(temp_dir, csv_name)
    CSV.open(domains_csv, "wb") do |csv|
      csv << [
        "Domain Name", "Description", "Option Name", "Option Value",
        "Missing Code", "Option Description"
      ]
      objects = []
      design_scope.each do |d|
        d.options_with_grid_sub_variables.each do |design_option|
          variable = design_option.variable
          objects << variable.domain if variable && variable.domain
        end
      end
      objects.uniq.each do |object|
        object.domain_options.each do |domain_option|
          csv << [
            object.name, object.description, domain_option.name,
            domain_option.value, domain_option.missing_code?,
            domain_option.description
          ]
        end
      end
    end
    update_steps(sheet_ids_count)
    [
      ["data_dictionary/#{designs_csv.split("/").last}", designs_csv],
      ["data_dictionary/#{variables_csv.split("/").last}", variables_csv],
      ["data_dictionary/#{domains_csv.split("/").last}", domains_csv],
      generate_readme(temp_dir, "data_dictionary")
    ]
  end

  def generate_statistic_export_from_erb(sheet_scope, temp_dir, filename, language)
    @export_formatter = ExportFormatter.new(sheet_scope, filename)

    erb_file = File.join("app", "views", "exports", "export.#{language}.erb")
    export_file = File.join(temp_dir, "#{filename}_#{language}.#{language}")

    File.open(export_file, "w") do |file|
      file.syswrite(ERB.new(File.read(erb_file)).result(binding))
    end

    [["#{language}/#{export_file.split("/").last}", export_file], generate_readme(temp_dir, language)]
  end

  def generate_r(sheet_scope, temp_dir, filename)
    generate_statistic_export_from_erb(sheet_scope, temp_dir, filename, "r")
  end

  def generate_sas(sheet_scope, temp_dir, filename)
    generate_statistic_export_from_erb(sheet_scope, temp_dir, filename, "sas")
  end

  def generate_readme(temp_dir, language, sheet_scope = Sheet.none)
    erb_file = File.join("test", "support", "exports", language, "README.erb")
    readme = File.join(temp_dir, "README_#{language}.txt")

    File.open(readme, "w") do |file|
      file.syswrite(ERB.new(File.read(erb_file)).result(binding))
    end

    ["#{language}/README.txt", readme]
  end

  def generate_csv_adverse_events(temp_dir, filename)
    export_file = Rails.root.join(temp_dir, "#{filename}_aes.csv")
    CSV.open(export_file, "wb") do |csv|
      csv << ["Adverse Event ID", "Reported By", "Subject", "Date of AE", "Description", "Status"]
      user.all_viewable_adverse_events.where(project_id: project.id).order(id: :desc).each do |ae|
        csv << [
          ae.number,
          ae.reported_by,
          ae.subject_code,
          ae.adverse_event_date,
          ae.description,
          ae.closed? ? "Closed" : "Open"
        ]
      end
    end
    ["csvs/#{filename}_aes.csv", export_file]
  end

  def generate_csv_adverse_events_master_list(temp_dir, filename)
    export_file = Rails.root.join(temp_dir, "#{filename}_aes_master_list.csv")
    CSV.open(export_file, "wb") do |csv|
      csv << ["Adverse Event ID", "Sheet ID"]
      user.all_viewable_adverse_events.where(project_id: project.id).order(id: :desc).each do |ae|
        ae.sheets.order(id: :desc).each do |sheet|
          csv << [ae.number, sheet.id]
        end
      end
    end
    ["csvs/#{filename}_aes_master_list.csv", export_file]
  end

  def generate_csv_randomizations(temp_dir, filename)
    export_file = Rails.root.join(temp_dir, "#{filename}_randomizations.csv")
    CSV.open(export_file, "wb") do |csv|
      randomizations = user.all_viewable_randomizations.where(project_id: project.id)
      schemes = project.randomization_schemes.where(id: randomizations.select(:randomization_scheme_id)).order(:name)
      column_headers = ["Randomization #", "Subject", "Treatment Arm", "List", "Randomized At", "Randomized By"]
      column_headers << "Scheme" if schemes.count > 1
      stratification_factors = []
      schemes.each do |scheme|
        scheme.stratification_factors.order(:name).each do |stratification_factor|
          column_headers << "#{stratification_factor.name}#{" (#{scheme.name})" if schemes.count > 1}"
          stratification_factors << stratification_factor
        end
      end
      csv << column_headers
      randomizations.includes(:subject, :treatment_arm, :list, :randomized_by, :randomization_scheme)
                    .order(Arel.sql("randomized_at desc nulls last")).select("randomizations.*").each do |r|
        row = [
          r.name,
          (r.subject ? r.subject.name : nil),
          (r.treatment_arm ? r.treatment_arm_name : nil),
          (r.list ? r.list.name : nil),
          r.randomized_at,
          (r.randomized_by ? r.randomized_by.full_name : nil)
        ]
        row << r.randomization_scheme.name if schemes.count > 1
        stratification_factors.each do |stratification_factor|
          row << randomization_characteristic_name(r, stratification_factor)
        end
        csv << row
      end
    end
    ["csvs/#{filename}_randomizations.csv", export_file]
  end

  def randomization_characteristic_name(randomization, stratification_factor)
    characteristic = randomization.randomization_characteristics.find_by(stratification_factor_id: stratification_factor.id)
    return unless characteristic
    sfo = characteristic.stratification_factor_option
    site = characteristic.site
    if sfo
      sfo.label
    elsif site
      site.name
    end
  end

  def all_design_variables_using_design_ids(design_ids)
    Variable.current.joins(:design_options)
            .where(design_options: { design_id: design_ids })
            .order("design_options.design_id", "design_options.position")
  end

  def generate_medications(temp_dir, filename)
    export_file = Rails.root.join(temp_dir, "#{filename}_medications.csv")
    medication_variable_names_and_ids = project.medication_variables.order(:id).pluck(:name, :id) # .order(:position)
    CSV.open(export_file, "wb") do |csv|
      column_headers = ["Medication ID", "Subject", "Name", "Start Date", "Stop Date"]

      medication_variable_names_and_ids.each do |name, _|
        column_headers << name
      end

      csv << column_headers
      project.medications.includes(:subject).find_each do |medication|
        row = [
          medication.id,
          medication.subject.name,
          medication.name,
          medication.start_date_fuzzy,
          medication.stop_date_fuzzy
        ]
        medication_variable_names_and_ids.each do |name, medication_variable_id|
          medication_value = medication.medication_values.find_by(medication_variable_id: medication_variable_id)
          row << medication_value&.value
        end

        csv << row
      end
    end
    ["csvs/#{filename}_medications.csv", export_file]
  end
end
