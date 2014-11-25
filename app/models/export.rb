class Export < ActiveRecord::Base

  after_create :calculate_total_steps

  mount_uploader :file, GenericUploader

  STATUS = ["ready", "pending", "failed"].collect{|i| [i,i]}

  # Concerns
  include Deletable, GridExport, SheetExport

  # Named Scopes
  scope :search, lambda { |arg| where("LOWER(exports.name) LIKE ?", arg.to_s.downcase.gsub(/^| |$/, '%')) }

  # Model Validation
  validates_presence_of :name, :user_id, :project_id

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods
  def notify_user!
    UserMailer.export_ready(self).deliver_later if Rails.env.production?
  end

  def self.filter(filters)
    scope = self.all
    filters.each_pair do |key, value|
      scope = scope.where(key => value) if self.column_names.include?(key.to_s) and not value.blank?
    end
    scope
  end

  def generate_export!(sheet_scope)
    begin
      filename = "#{self.name.gsub(/[^a-zA-Z0-9_-]/, '_')}_#{self.created_at.strftime("%H%M")}"

      all_files = [] # If numerous files are created then they need to be zipped!

      all_files << generate_csv_sheets(sheet_scope, filename, false, 'csv') if self.include_csv_labeled?
      all_files << generate_csv_grids(sheet_scope, filename, false, 'csv')  if self.include_csv_labeled?
      all_files << generate_csv_sheets(sheet_scope, filename, true, 'csv')  if self.include_csv_raw?
      all_files << generate_csv_grids(sheet_scope, filename, true, 'csv')   if self.include_csv_raw?
      all_files << generate_readme('csv')                                   if self.include_csv_labeled? or self.include_csv_raw?
      all_files += generate_pdf(sheet_scope, filename)                      if self.include_pdf?
      all_files += generate_data_dictionary(sheet_scope, filename)          if self.include_data_dictionary?
      all_files += generate_sas(sheet_scope, filename)                      if self.include_sas?
      all_files << generate_csv_sheets(sheet_scope, filename, true, 'sas')  if self.include_sas?
      all_files << generate_csv_grids(sheet_scope, filename, true, 'sas')   if self.include_sas?

      all_files += generate_r(sheet_scope, filename)                      if self.include_r?
      all_files << generate_csv_sheets(sheet_scope, filename, true, 'r')  if self.include_r?
      all_files << generate_csv_grids(sheet_scope, filename, true, 'r')   if self.include_r?

      if self.include_files?
        sheet_scope.each do |sheet|
          all_files += sheet.files
          update_steps(1)
        end
        all_files << generate_readme('files')
      end

      # Zip multiple files, or zip one file if it's part of the sheet uploaded files
      # Always Zip folder
      export_file = if all_files.size > 0
        # Create a zip file
        zipfile_name = File.join('tmp', 'files', 'exports', "#{filename} #{Digest::SHA1.hexdigest(Time.now.usec.to_s)[0..8]}.zip")
        Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
          all_files.uniq.each do |location, input_file|
            # Two arguments:
            # - The name of the file as it will appear in the archive
            # - The original file, including the path to find it
            zipfile.add(location, input_file) if File.exists?(input_file) and File.size(input_file) > 0
          end
        end
        zipfile_name
      end

      if export_file.blank? and self.include_files?
        self.update_attributes status: 'failed', details: "No sheets have had files uploaded. Zip file not created."
      elsif export_file.blank?
        self.update_attributes status: 'failed', details: "No files were created. At least one file type needs to be selected for exports."
      else
        self.update_attributes file: File.open(export_file), file_created_at: Time.now, status: 'ready', steps_completed: self.total_steps
        self.notify_user!
      end
    rescue => e
      self.update_attributes status: 'failed', details: e.message.to_s + e.backtrace.to_s
      Rails.logger.debug "Error: #{e}"
      puts "Error: #{e.inspect}"
      puts e.backtrace
    end
  end


  private

    def calculate_total_steps
      steps = 0
      steps += sheet_ids_count if self.include_csv_labeled?
      steps += sheet_ids_count if self.include_csv_labeled?
      steps += sheet_ids_count if self.include_csv_raw?
      steps += sheet_ids_count if self.include_csv_raw?
      steps += sheet_ids_count if self.include_sas?
      steps += sheet_ids_count if self.include_sas?
      steps += sheet_ids_count if self.include_pdf?
      steps += sheet_ids_count if self.include_data_dictionary?
      steps += sheet_ids_count if self.include_r?
      steps += sheet_ids_count if self.include_files?
      self.update_column :total_steps, steps
    end

    def update_steps(amount)
      self.update_column :steps_completed, self.steps_completed + amount
    end

    def generate_pdf(sheet_scope, filename)
      pdf_file = Sheet.latex_file_location(sheet_scope, self.user)
      update_steps(self.sheet_ids_count)
      [["PDF/#{pdf_file.split('/').last}", pdf_file], generate_readme('pdf')]
    end

    def generate_data_dictionary(sheet_scope, filename)
      design_scope = Design.where(id: sheet_scope.pluck(:design_id)).order('name')

      designs_csv = File.join('tmp', 'files', 'exports', "#{self.name.gsub(/[^a-zA-Z0-9_-]/, '_')} #{self.created_at.strftime("%I%M%P")}_designs.csv")

      CSV.open(designs_csv, "wb") do |csv|
        csv << ['Design Name', 'Name', 'Display Name', 'Branching Logic', 'Description']

        design_scope.each do |d|
          d.options.each do |option|
            if option[:variable_id].blank?
              csv << [ d.name, option[:section_id], option[:section_name], option[:branching_logic], option[:section_description] ]
            elsif variable = Variable.current.find_by_id(option[:variable_id])
              csv << [ d.name, variable.name, variable.display_name, option[:branching_logic], variable.description ]
            end
          end
        end
      end

      variables_csv = File.join('tmp', 'files', 'exports', "#{self.name.gsub(/[^a-zA-Z0-9_-]/, '_')} #{self.created_at.strftime("%I%M%P")}_variables.csv")

      CSV.open(variables_csv, "wb") do |csv|
        csv << [  'Design Name', 'Variable Name', 'Variable Display Name', 'Variable Description',
                  'Variable Type', 'Hard Min', 'Soft Min', 'Soft Max', 'Hard Max', 'Calculation', 'Prepend', 'Units',
                  'Append', 'Format', 'Multiple Rows', 'Autocomplete Values', 'Show Current Button',
                  'Display Name Visibility', 'Alignment', 'Default Row Number', 'Domain Name' ]
        design_scope.each do |d|
          d.options_with_grid_sub_variables.each do |option|
            if option[:variable_id].blank?
              csv << [ d.name,
                option[:section_id],
                option[:section_name],
                option[:section_description], # Variable Description
                (option[:section_type].to_i > 0 ? 'subsection' : 'section'),
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
                nil ] # Domain Name
            elsif variable = Variable.current.find_by_id(option[:variable_id])
              csv << [ d.name,
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
                (variable.domain ? variable.domain.name : '') ] # Domain Name
            end
          end
        end
      end

      domains_csv = File.join('tmp', 'files', 'exports', "#{self.name.gsub(/[^a-zA-Z0-9_-]/, '_')} #{self.created_at.strftime("%I%M%P")}_domains.csv")

      CSV.open(domains_csv, "wb") do |csv|
        csv << [ 'Domain Name', 'Description', 'Option Name', 'Option Value', 'Missing Code', 'Option Description' ]

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
            csv << [ object.name, object.description, opt[:name], opt[:value], opt[:missing_code], opt[:description] ]
          end
        end
      end

      update_steps(self.sheet_ids_count)
      [ ["DD/#{designs_csv.split('/').last}", designs_csv], ["DD/#{variables_csv.split('/').last}", variables_csv], ["DD/#{domains_csv.split('/').last}", domains_csv], generate_readme('dd', sheet_scope) ]
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
      erb_file = File.join('test', 'support', 'exports', language, "README.erb")
      readme = File.join('tmp', 'files', 'exports', "README_#{language}_#{Time.now.strftime("%Y%m%d_%H%M%S")}.txt")

      File.open(readme, 'w') do |file|
        file.syswrite(ERB.new(File.read(erb_file)).result(binding))
      end

      ["#{language.upcase}/README.txt", readme]
    end

    def all_design_variables_without_grids(sheet_scope)
      Design.where(id: sheet_scope.pluck(:design_id)).collect(&:variables).flatten.uniq.select{|v| v.variable_type != 'grid'}
    end

end
