class Export < ActiveRecord::Base

  after_create :calculate_total_steps

  mount_uploader :file, GenericUploader

  STATUS = ["ready", "pending", "failed"].collect{|i| [i,i]}

  # Concerns
  include Deletable

  # Named Scopes
  scope :search, lambda { |arg| where("LOWER(exports.name) LIKE ?", arg.to_s.downcase.gsub(/^| |$/, '%')) }

  # Model Validation
  validates_presence_of :name, :user_id, :project_id

  # Model Relationships
  belongs_to :user
  belongs_to :project

  # Model Methods
  def notify_user!
    UserMailer.export_ready(self).deliver if Rails.env.production?
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
      steps += sheet_ids_count if self.include_sas?
      steps += sheet_ids_count if self.include_files?
      self.update_column :total_steps, steps
    end

    def update_steps(amount)
      self.update_column :steps_completed, self.steps_completed + amount
    end

    def generate_csv_sheets(sheet_scope, filename, raw_data, folder)
      export_file = File.join('tmp', 'files', 'exports', "#{filename}_#{raw_data ? 'raw' : 'labeled'}.csv")

      rows = []

      sheet_scope.includes( sheet_variables: [ :variable ] ).each do |sheet|
        hash = { sheet: sheet }
        sheet.sheet_variables.each do |sv|
          unless sv.variable.variable_type == 'grid'
            response = (raw_data ? sv.get_response(:raw) : sv.get_response(:name))
            hash[sv.variable_id.to_s] = response
            hash[sv.variable_id.to_s] = hash[sv.variable_id.to_s].join(',') if hash[sv.variable_id.to_s].kind_of?(Array)
            if sv.variable.variable_type == 'checkbox'
              sv.variable.shared_options.each_with_index do |option, index|
                search_string = (raw_data ? option[:value] : "#{option[:value]}: #{option[:name]}")
                hash["#{sv.variable_id.to_s}__#{option[:value]}"] = search_string if response.include?(search_string)
              end
            end
          end
        end
        rows << hash
        update_steps(1)
      end

      CSV.open(export_file, "wb") do |csv|
        variables = all_design_variables_without_grids(sheet_scope)
        column_headers = variables.collect(&:csv_column).flatten
        column_ids = variables.collect(&:csv_column_ids).flatten
        csv << ["Sheet ID", "Name", "Description", "Sheet Creation Date", "Project", "Site", "Subject", "Acrostic", "Status", "Creator", "Schedule Name", "Event Name"] + column_headers
        rows.each do |hash|
          sheet = hash[:sheet]
          row = [ sheet.id,
                  sheet.name,
                  sheet.description,
                  sheet.created_at.strftime("%Y-%m-%d"),
                  sheet.project.name,
                  sheet.subject.site.name,
                  sheet.subject.name,
                  sheet.project.acrostic_enabled? ? sheet.subject.acrostic : nil,
                  sheet.subject.status,
                  sheet.user ? sheet.user.name : nil,
                  sheet.subject_schedule ? sheet.subject_schedule.name : nil,
                  sheet.event ? sheet.event.name : nil ]
          column_ids.each do |column_id|
            row << hash[column_id]
          end
          csv << row
        end
      end
      ["#{folder.upcase}/#{export_file.split('/').last}", export_file]
    end

    def generate_csv_grids(sheet_scope, filename, raw_data, folder)
      export_file = File.join('tmp', 'files', 'exports', "#{filename}_grids_#{raw_data ? 'raw' : 'labeled'}.csv")

      rows = []

      sheet_scope.includes( sheet_variables: [ :variable, { grids: :variable } ] ).each do |sheet|
        hash = { sheet: sheet, rows: [] }
        sheet.sheet_variables.each do |sv|
          if sv.variable.variable_type == 'grid'
            sv.grids.each do |grid|
              hash[:rows][grid.position] ||= {}
              hash[:rows][grid.position][sv.variable_id.to_s] ||= {}

              result = (raw_data ? grid.get_response(:raw) : grid.get_response(:name))
              result = result.join(',') if result.kind_of?(Array)

              hash[:rows][grid.position][sv.variable_id.to_s][grid.variable_id.to_s] = result
            end
          end
        end
        rows << hash
        update_steps(1)
      end

      CSV.open(export_file, "wb") do |csv|
        variable_ids = Design.where(id: sheet_scope.pluck(:design_id)).collect(&:variable_ids).flatten.uniq
        grid_group_variables = Variable.current.where(variable_type: 'grid', id: variable_ids)

        row = ["", "", "", "", "", "", "", "", "", "", "", ""]

        grid_group_variables.each do |variable|
          variable.grid_variables.each do |grid_variable_hash|
            grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
            row << variable.name if grid_variable
          end
        end

        csv << row

        row = ["Sheet ID", "Name", "Description", "Sheet Creation Date", "Project", "Site", "Subject", "Acrostic", "Status", "Creator", "Schedule Name", "Event Name"]

        grid_group_variables.each do |variable|
          variable.grid_variables.each do |grid_variable_hash|
            grid_variable = Variable.current.find_by_id(grid_variable_hash[:variable_id])
            row << grid_variable.name if grid_variable
          end
        end

        csv << row

        rows.each do |hash|
          sheet = hash[:sheet]

          hash[:rows].each do |sheet_row|
            row = [ sheet.id,
                    sheet.name,
                    sheet.description,
                    sheet.created_at.strftime("%Y-%m-%d"),
                    sheet.project.name,
                    sheet.subject.site.name,
                    sheet.subject.name,
                    sheet.project.acrostic_enabled? ? sheet.subject.acrostic : nil,
                    sheet.subject.status,
                    sheet.user ? sheet.user.name : nil,
                    sheet.subject_schedule ? sheet.subject_schedule.name : nil,
                    sheet.event ? sheet.event.name : nil ]

            grid_group_variables.each do |variable|
              variable.grid_variables.each do |grid_variable_hash|
                row << (sheet_row[variable.id.to_s].blank? ? '' : sheet_row[variable.id.to_s][grid_variable_hash[:variable_id].to_s])
              end
            end
            csv << row
          end
        end
      end

      ["#{folder.upcase}/#{export_file.split('/').last}", export_file]
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

    def generate_sas(sheet_scope, filename)
      export_file = File.join('tmp', 'files', 'exports', "#{filename}_sas.sas")
      design_scope = Design.where(id: sheet_scope.pluck(:design_id))
      variables = all_design_variables_without_grids(sheet_scope)
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

      update_steps(self.sheet_ids_count)

      [["SAS/#{export_file.split('/').last}", export_file], generate_readme('sas')]
    end

    def sas_header(filename)
      <<-eos
/* Generated by Slice v#{Slice::VERSION::STRING} */
/*           on #{Time.now.strftime("%a, %B %d, %Y at %-l:%M%p")} */

/* YOU WILL NEED TO MODIFY IMPORT FOLDER */
/* TO POINT TO THE LOCATION WHERE YOU    */
/* DOWNLOADED THE CSV AND SAS FILES      */

%let a=%sysget(SAS_EXECFILEPATH);
%let b=%sysget(SAS_EXECFILENAME);

%let path_file= %sysfunc(tranwrd(&a,&b,#{filename}_raw));
%let path_file_grids= %sysfunc(tranwrd(&a,&b,#{filename}_grids_raw));

      eos
    end

    def sas_step1(variables, use_grids)
      column_headers = variables.collect(&:csv_column).flatten
      column_informats = variables.collect(&:sas_informat_definition).flatten
      column_formats = variables.collect(&:sas_format_definition).flatten

      <<-eos
/* Replace carriage returns inside delimiters */
data _null_;
  infile "&path_file#{'_grids' if use_grids}..csv" recfm=n;
  file "&path_file#{'_grids' if use_grids}._sas.csv" recfm=n;
  input a $char1.;
  retain open 0;
  if a='"' then open=not open;
  if (a='0A'x or a='0D'x) and open then put '00'x @;
  else put a $char1. @;
run;

/* Step 1: Import data into slice work library */

data slice#{'_grids' if use_grids};
  infile "&path_file#{'_grids' if use_grids}._sas.csv" delimiter = ',' MISSOVER DSD lrecl=32767 firstobs=#{use_grids ? 3 : 2} ;

  /* Design and Subject Variables */
  informat sheet_id             best32.   ;   * Sheet ID ;
  informat name                 $500.     ;   * Design name ;
  informat description          $5000.    ;   * Design description ;
  informat sheet_creation_date  yymmdd10. ;   * Sheet creation date ;
  informat project              $500.     ;   * Project name ;
  informat site                 $500.     ;   * Subject site name ;
  informat subject              $100.     ;   * Subject code ;
  informat acrostic             $100.     ;   * Subject acrostic ;
  informat status               $10.      ;   * Subject status ;
  informat creator              $100.     ;   * Sheet creator ;
  informat schedule_name        $500.     ;   * Schedule name ;
  informat event_name           $500.     ;   * Event name ;

  /* Sheet Variables */
#{column_informats.join("\n")}

  /* Design and Subject Variables */
  format sheet_id               best32.   ;
  format name                   $500.     ;
  format description            $500.     ;
  format sheet_creation_date    yymmdd10. ;
  format project                $500.     ;
  format site                   $500.     ;
  format subject                $100.     ;
  format acrostic               $100.     ;
  format status                 $10.      ;
  format creator                $100.     ;
  format schedule_name          $500.     ;
  format event_name             $500.     ;

  /* Sheet Variables */
#{column_formats.join("\n")}

  /* Define Column Names */

  input
    sheet_id
    name
    description
    sheet_creation_date
    project
    site
    subject
    acrostic
    status
    creator
    schedule_name
    event_name
#{column_headers.collect{|c| "    #{c}"}.join("\n")}
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
  label sheet_id='Sheet ID';
  label name='Design Name';
  label description='Design Description';
  label sheet_creation_date='Sheet Creation Date';
  label project='Project';
  label site='Site';
  label subject='Subject ID';
  label acrostic='Subject Acrostic';
  label status='Subject Status';
  label creator='Sheet Creator';
  label schedule_name='Schedule Name';
  label event_name='Event Name';

  /* Sheet Variables */
#{variables.collect{|v| "  label #{v.name}='#{v.display_name.gsub("'", "''")}';" }.join("\n")}
run;

      eos
    end

    def sas_step3(domains, use_grids)
      <<-eos
/* Step 3: Create formats for slice domain options */

proc format;
#{domains.collect{ |d| d.sas_value_domain }.join("\n")}
run;

      eos
    end

    def sas_step4(variables, use_grids)
      <<-eos
/* Step 4: Apply format to all of the variables */

data slice#{'_grids' if use_grids};
  set slice#{'_grids' if use_grids};

#{variables.collect{|v| (v.variable_type != 'checkbox' and v.domain) ? "  format #{v.name} #{v.domain.sas_domain_name}. ;" : nil }.compact.join("\n")}
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

    def generate_readme(readme_type, sheet_scope = Sheet.none)
      erb_file = File.join('test', 'support', 'exports', readme_type, "README.erb")
      readme = File.join('tmp', 'files', 'exports', "README_#{readme_type}_#{Time.now.strftime("%Y%m%d_%H%M%S")}.txt")

      File.open(readme, 'w') do |file|
        file.syswrite(ERB.new(File.read(erb_file)).result(binding))
      end

      ["#{readme_type.upcase}/README.txt", readme]
    end

    def all_design_variables_without_grids(sheet_scope)
      Design.where(id: sheet_scope.pluck(:design_id)).collect(&:variables).flatten.uniq.select{|v| v.variable_type != 'grid'}
    end

end
