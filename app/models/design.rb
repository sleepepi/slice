class Design < ActiveRecord::Base
  mount_uploader :csv_file, SpreadsheetUploader

  serialize :options, Array

  # Callbacks
  before_save :check_option_validations
  after_save :reset_sheet_total_response_count, :set_slug

  QUESTION_TYPES = [['free text', 'string'], ['select one answer', 'radio'], ['select multiple answers', 'checkbox'], ['date', 'date'], ['time', 'time'], ['number', 'numeric'], ['file upload', 'file']]

  # Concerns
  include Searchable, Deletable, Latexable, DateAndTimeParser

  attr_writer :questions

  # Named Scopes
  scope :with_user, lambda { |arg| where(user_id: arg) }
  scope :with_project, lambda { |arg| where(project_id: arg) }

  scope :order_by_user_name, lambda { joins("LEFT JOIN users ON users.id = designs.user_id").order('users.last_name, users.first_name') }
  scope :order_by_user_name_desc, lambda { joins("LEFT JOIN users ON users.id = designs.user_id").order('users.last_name DESC, users.first_name DESC') }

  # Model Validation
  validates_presence_of :name, :user_id, :project_id
  validates_uniqueness_of :name, scope: [:deleted, :project_id]
  validates_uniqueness_of :slug, allow_blank: true, scope: :deleted

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :sheets, -> { where deleted: false }
  has_many :sections
  belongs_to :updater, class_name: 'User', foreign_key: 'updater_id'
  has_many :event_designs

  has_many :design_options, -> { order :position }
  has_many :dbvariables, through: :design_options, source: :variable


  # Model Methods

  def options
    []
  end

  def questions
    @questions || [ { question_name: '', question_type: 'free text' } ]
  end

  def create_section(params, position, current_user)
    errors = []
    section_params = params.permit(:section_name, :section_description, :section_branching_logic, :section_type, :section_image)
    section_hash = { section_name: section_params[:section_name].to_s.strip, section_id: "_" + section_params[:section_name].to_s.strip.gsub(/[^\w]/,'_').downcase, section_description: section_params[:section_description].to_s.strip, section_type: section_params[:section_type].to_i, branching_logic: section_params[:branching_logic].to_s.strip }
    unless section_params[:section_name].to_s.strip.blank?
      new_option_tokens = self.options
      new_option_tokens.insert(position, section_hash)
      self.options = new_option_tokens
      if self.save
        section = self.sections.where( name: section_hash[:section_name] ).first_or_create( project_id: self.project_id, user_id: current_user.id )
        section.update( description: section_hash[:description], sub_section: section_hash[:section_type] == 1, image: section_params[:section_image], branching_logic: section_params[:section_branching_logic] )
      else
        errors += [['section_section_name', 'Section name must be unique!']]
      end
    else
      errors += [['section_section_name', 'Section name can\'t be blank!']]
    end
    errors
  end

  def update_section(params, position, current_user)
    errors = []
    section_params = params.permit(:section_name, :section_description, :section_branching_logic, :section_type, :section_image)
    unless section_params[:section_name].blank?
      section_params[:section_id] = "_" + section_params[:section_name].to_s.strip.gsub(/[^\w]/,'_').downcase
      new_option_tokens = self.options
      section_params.each do |key, value|
        new_option_tokens[position][key.to_sym] = value.to_s.strip
      end
      self.options = new_option_tokens
      if self.save
        section = self.sections.where( name: section_params[:section_name] ).first_or_create( project_id: self.project_id, user_id: current_user.id )
        section.update( description: section_params[:section_description], sub_section: section_params[:section_type] == 1, image: section_params[:section_image], branching_logic: section_params[:section_branching_logic] )
      else
        errors += [['section_section_name', 'Section name must be unique!']]
      end
    else
      errors += [['section_section_name', 'Section name can\'t be blank!']]
    end
    errors
  end

  def create_domain(params, variable_id, current_user)
    errors = []
    variable = self.project.variables.find_by_id(variable_id)
    if params[:id].blank?
      params = Domain.clean_option_tokens(params)
      domain_params = params.permit(:name, :display_name, :description, { :option_tokens => [ :name, :value, :description, :missing_code, :option_index ] })
      domain_params[:user_id] = current_user.id
      domain = self.project.domains.new( domain_params )
      if variable and variable.values_cover_collected_values?(domain.values)
        domain.save
      else
        errors = [["domain_name", "Domain options do not cover collected values!"]]
      end
    else
      domain = self.project.domains.find_by_id(params[:id])
    end
    if domain and not domain.new_record? and variable
      variable.update(domain_id: domain.id)
      errors += [["domain_name", "Domain options do not cover collected values!"]] if variable.errors.any?
    else
      errors += domain.errors.messages.collect{|key, errors| ["domain_#{key.to_s}", "Domain #{key.to_s.humanize.downcase} #{errors.first}"]}
    end
    errors
  end

  def update_domain(params, variable_id)
    errors = []
    variable = self.project.variables.find_by_id(variable_id)
    if variable and variable.domain
      params = Domain.clean_option_tokens(params)
      domain_params = params.permit(:name, :display_name, :description, { :option_tokens => [ :name, :value, :description, :missing_code, :option_index ] })
      variable.domain.update( domain_params )
      if variable.domain.errors.any?
        errors += variable.domain.errors.messages.collect{|key, errors| ["domain_#{key.to_s}", "Domain #{key.to_s.humanize.downcase} #{errors.first}"]}
      end
    end
    errors
  end

  def create_variable(params, position)
    errors = []
    if params[:id].blank?
      params[:display_name_visibility] = 'gone' if params[:variable_type].to_s == 'text'
      variable_params = params.permit(:name, :display_name, :variable_type, :display_name_visibility)
      variable = self.project.variables.create( variable_params )
      if not variable.new_record? and variable.variable_type == 'grid' and not params[:questions].blank?
        variable.create_variables_from_questions!(params[:questions])
      end
    else
      variable = self.project.variables.find_by_id(params[:id])
    end
    if variable and not variable.new_record?
      new_option_tokens = self.options
      new_option_tokens.insert(position, { variable_id: variable.id, branching_logic: '', required: '' })
      self.options = new_option_tokens
      self.save
    else
      errors += variable.errors.messages.collect{|key, errors| ["variable_#{key.to_s}", "Variable #{key.to_s.humanize.downcase} #{errors.first}"]}
    end
    errors
  end

  def update_variable(params, position, variable_id)
    errors = []
    option_params = params.permit(:branching_logic, :required)
    unless option_params.blank?
      new_option_tokens = self.options
      option_params.each do |key, value|
        new_option_tokens[position][key.to_sym] = value.to_s.strip
      end
      self.options = new_option_tokens
      self.save
    end

    [:date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum].each do |date|
      params[date] = parse_date(params[date]) if params[date]
    end

    variable_params = params.permit(:name, :display_name, :prepend, :append, :units, :variable_type, :display_name_visibility, :calculation, :format, :hard_minimum, :hard_maximum, :soft_minimum, :soft_maximum, :alignment, :date_hard_maximum, :date_hard_minimum, :date_soft_maximum, :date_soft_minimum, :show_current_button, :autocomplete_values, :multiple_rows, :default_row_number, { :grid_tokens => [ :variable_id ] })
    if v = self.project.variables.find_by_id(variable_id)
      v.update(variable_params)
      if v.errors.any?
        errors += v.errors.messages.collect{|key, errors| ["variable_#{key.to_s}", "Variable #{key.to_s.humanize.downcase} #{errors.first}"]}
      end
    end
    errors
  end

  def create_variables_from_questions!
    self.questions.select{|hash| not hash[:question_name].blank?}.each_with_index do |question_hash, position|
      name = question_hash[:question_name].to_s.downcase.gsub(/[^a-zA-Z0-9]/, '_').gsub(/^[\d_]/, 'n').gsub(/_{2,}/, '_').gsub(/_$/, '')[0..31].strip
      name = "var_#{Digest::SHA1.hexdigest(Time.now.usec.to_s)[0..27]}" if self.project.variables.where( name: name ).size != 0
      params = ActionController::Parameters.new( variable_type: QUESTION_TYPES.collect{|name,value| value}.include?(question_hash[:question_type]) ? question_hash[:question_type] : 'string', name: name, display_name: question_hash[:question_name] )
      self.create_variable(params, position)
    end
  end

  def remove_option(position)
    new_option_tokens = self.options
    new_option_tokens.delete_at(position)
    self.options = new_option_tokens
    self.save
  end

  def variable_at(position)
    variable = Variable.find_by_id(self.options[position][:variable_id]) if self.options[position]
  end

  def editable_by?(current_user)
    current_user.all_designs.where(id: self.id).count == 1
  end

  def copyable_attributes
    self.attributes.reject{|key, val| ['id', 'slug', 'user_id', 'deleted', 'created_at', 'updated_at'].include?(key.to_s)}
  end

  # We want all validations to run so all errors will show up when submitting a form
  def check_option_validations
    result_a = check_variable_ids
    result_b = check_section_names

    result_a and result_b
  end

  def check_variable_ids
    result = true
    if self.variable_ids.uniq.size < self.variable_ids.size
      self.errors.add(:variables, "can only be added once")
      result = false
    end
    result
  end

  def check_section_names
    result = true
    if self.section_names.uniq.size < self.section_names.size
      self.errors.add(:section_names, "must be unique")
      result = false
    end
    result
  end

  def options_with_grid_sub_variables
    new_options = []
    self.options.each do |option|
      new_options << option
      if v = Variable.current.where(variable_type: 'grid').find_by_id(option[:variable_id])
        v.grid_variables.each do |grid_variable|
          new_options << { variable_id: grid_variable[:variable_id], branching_logic: '' }
        end
      end
    end
    new_options
  end

  def option_tokens=(tokens)
    self.options = []
    tokens.each do |option_hash|
      if option_hash[:section_name].blank?
        self.options << {
                          variable_id: option_hash[:variable_id],
                          branching_logic: option_hash[:branching_logic].to_s.strip
                        } unless option_hash[:variable_id].blank?
      else
        self.options << {
                          section_name: option_hash[:section_name].strip,
                          section_id: "_" + option_hash[:section_name].strip.gsub(/[^\w]/,'_').downcase,
                          section_description: option_hash[:section_description].to_s.strip,
                          section_type: option_hash[:section_type].to_i,
                          branching_logic: option_hash[:branching_logic].to_s.strip
                        }
      end
    end
  end

  def branching_logic_section(section)
    if section
      section.branching_logic.to_s.gsub(/([a-zA-Z]+[\w]*)/){|m| variable_replacement($1)}.to_json
    else
      ''.to_json
    end
  end

  def branching_logic(variable)
    self.options.select{|item| item[:variable_id].to_i == variable.id }.collect{|item| item[:branching_logic].to_s.gsub(/([a-zA-Z]+[\w]*)/){|m| variable_replacement($1)}}.join(' ').to_json
  end

  def variable_replacement(variable_name)
    variable = self.pure_variables.find_by_name(variable_name)
    if variable and ['radio'].include?(variable.variable_type)
      "$(\"[name='variables[#{variable.id}]']:checked\").val()"
    elsif variable and ['checkbox'].include?(variable.variable_type)
      "$.map($(\"[name='variables[#{variable.id}][]']:checked\"),function(el){return $(el).val();})"
    elsif variable
      "$(\"#variables_#{variable.id}\").val()"
    else
      variable_name
    end
  end

  def variable_ids
    @variable_ids ||= begin
      self.options.select{|option| not option[:variable_id].blank?}.collect{|option| option[:variable_id].to_i}
    end
  end

  def subsections(section_name)
    section_index = (self.options.index{|opt| opt[:section_name] == section_name} + 1) rescue nil
    section_subsections = []
    if section_index >= 0
      self.options[section_index..-1].select{|o| not o[:section_name].blank?}.each do |option|
        break if option[:section_type].to_i == 0
        section_subsections << option
      end
    end
    section_subsections
  end

  def main_sections
    self.options.select{|option| not option[:section_name].blank? and option[:section_type].to_i == 0}
  end

  def all_sections
    self.options.select{|option| not option[:section_name].blank?}
  end

  def section_names
    @section_names ||= begin
      self.all_sections.collect{|option| option[:section_name]}
    end
  end

  def main_section_names
    self.main_sections.collect{|option| option[:section_name]}
  end

  # ActiveRecord...
  def pure_variables
    @pure_variables ||= begin
      Variable.current.where(id: variable_ids)
    end
  end

  # Array...
  def variables
    pure_variables.sort{ |a, b| variable_ids.index(a.id) <=> variable_ids.index(b.id) }
  end

  def reportable_variables(variable_types, except_variable_ids = [0])
    self.pure_variables.where("variables.id NOT IN (?)", except_variable_ids).where(variable_type: variable_types).sort{ |a, b| variable_ids.index(a.id) <=> variable_ids.index(b.id) }.collect{|v| [self.containing_section(v.id), v.display_name, v.id]}
  end

  def grouped_reportable_variables(variable_types, except_variable_ids = [0])
    reportable_variables(variable_types, except_variable_ids).group_by{|a| a[0]}.collect{|section, values| [section, values.collect{|a| [a[1], a[2]]}]}
  end

  def containing_section(variable_id)
    location = self.options.collect{|h| h[:variable_id].to_i}.index(variable_id)
    self.options[0..location].select{|option| not option[:section_name].blank?}.collect{|option| option[:section_name]}.last
  end

  def reorder_sections(section_order, current_user)
    return if section_order.size == 0 or section_order.sort != (0..self.main_section_names.size - 1).to_a
    original_sections = {}

    current_section = nil
    range_start = 0
    section_count = 0
    self.options.each_with_index do |option, index|
      if option[:section_name].blank? or option[:section_type].to_i > 0
        original_sections[current_section] = [range_start, index]
      else
        current_section = section_count
        section_count += 1
        range_start = index
        original_sections[current_section] = [range_start, index]
      end
    end

    rows = original_sections[nil].blank? ? [] : (original_sections[nil][0]..original_sections[nil][1]).to_a

    section_order.each do |position|
      rows = rows + (original_sections[position][0]..original_sections[position][1]).to_a
    end

    self.reorder_options(rows, current_user)
  end

  def reorder_options(row_order, current_user)
    return if row_order.size == 0 or row_order.sort != (0..self.options.size - 1).to_a

    original_options = self.options
    new_options = []

    row_order.each_with_index do |row, new_location|
      old_location = row
      new_options << original_options[old_location]
    end

    # Only change if the options match up
    if new_options.size == original_options.size
      self.update_attributes updater_id: current_user.id, options: new_options
      self.reload
    end
  end

  def latex_partial(partial)
    File.read(File.join('app', 'views', 'designs', 'latex', "_#{partial}.tex.erb"))
  end

  def latex_file_location(current_user)
    jobname = "design_#{self.id}"
    output_folder = File.join('tmp', 'files', 'tex')
    file_tex = File.join('tmp', 'files', 'tex', jobname + '.tex')

    File.open(file_tex, 'w') do |file|
      file.syswrite(ERB.new(latex_partial('print')).result(binding))
    end

    Design.generate_pdf(jobname, output_folder, file_tex)
  end

  def latex_report_new_file_location(current_user, orientation, report_title, report_subtitle, report_caption, percent, table_header, table_body, table_footer)
    @design = self
    @project = @design.project
    @report_title = report_title
    @report_subtitle
    @report_caption = report_caption
    @percent = percent
    @table_header = table_header
    @table_body = table_body
    @table_footer = table_footer

    jobname = "project_#{@project.id}_design_#{self.id}_report"
    output_folder = File.join('tmp', 'files', 'tex')
    file_tex = File.join('tmp', 'files', 'tex', jobname + '.tex')

    File.open(file_tex, 'w') do |file|
      file.syswrite(ERB.new(latex_partial('report_new')).result(binding))
    end

    Design.generate_pdf(jobname, output_folder, file_tex)
  end

  def load_variables
    @load_variables ||= begin
      raw_variables = self.header_row
      raw_variables.select!{|i| not ['Subject', 'Acrostic'].include?(i)}
      variables = []
      raw_variables.each do |variable_token|
        (variable_name, variable_type) = variable_token.to_s.split(':')
        variable_type = 'string' unless Variable::TYPE_IMPORTABLE.flatten.include?(variable_type)
        variables << { name: variable_name.gsub(/[^a-zA-Z_0-9]/, ''), display_name: variable_name.humanize, variable_type: variable_type, column_name: variable_token } unless variable_name.blank?
      end
      variables
    end
  end

  def header_row
    @header_row ||= begin
      result = []
      if self.csv_file.path
        current_line = 0
        CSV.parse( File.open(self.csv_file.path, 'r:iso-8859-1:utf-8'){|f| f.read} ) do |line|
          break unless current_line == 0
          result = line
          current_line += 1
        end
      end
      result
    end
  end

  def create_variables!(variable_hashes)
    new_variable_ids = []
    variable_hashes.each do |name, hash|
      v = self.project.variables.find_by_name(name.to_s)
      next if hash[:ignore] == '1' or (not v and not Variable::TYPE_IMPORTABLE.flatten.include?(hash[:variable_type]))
      v = self.project.variables.create( name: name, display_name: hash[:display_name], variable_type: hash[:variable_type], updater_id: self.id, user_id: self.user_id ) unless v
      new_variable_ids << v.id if v
    end

    self.options = new_variable_ids.uniq.collect{ |vid| { variable_id: vid.to_s, branching_logic: "" } }
    self.save

    self.set_total_rows
  end

  def set_total_rows
    counter = 0
    CSV.parse( File.open(self.csv_file.path, 'r:iso-8859-1:utf-8'){|f| f.read}, headers: true ){ counter += 1 } if self.csv_file.path
    self.update( total_rows: counter )
  end

  def create_sheets!(default_site, default_status, current_user, remote_ip)
    if self.csv_file.path and default_site
      self.update( import_started_at: Time.now )
      self.set_total_rows
      counter = 0
      CSV.parse( File.open(self.csv_file.path, 'r:iso-8859-1:utf-8'){|f| f.read}, headers: true ) do |line|
        row = line.to_hash.with_indifferent_access
        subject = Subject.first_or_create_with_defaults(self.project, row['Subject'], row['Acrostic'].to_s, current_user, default_site, default_status)
        if subject
          sheet = self.sheets.where( subject_id: subject.id ).first_or_initialize( project_id: self.project_id, user_id: current_user.id, last_user_id: current_user.id )
          transaction_type = (sheet.new_record? ? 'sheet_create' : 'sheet_update')
          variables_params = {}
          self.load_variables.each do |hash|
            variable = self.project.variables.find_by_name(hash[:name])
            if variable and Variable::TYPE_IMPORTABLE.flatten.include?(variable.variable_type)
              variables_params[variable.id.to_s] = row[hash[:column_name]].to_s
            end
          end
          SheetTransaction.save_sheet!(sheet, {}, variables_params, current_user, remote_ip, transaction_type)
        end
        counter += 1
        self.update( rows_imported: counter ) if counter % 25 == 0 or counter == self.total_rows
      end
    end

    self.update( import_ended_at: Time.now )
    self.notify_user!(current_user)
  end

  def notify_user!(current_user)
    UserMailer.import_complete(self, current_user).deliver_later if Rails.env.production?
  end

  private

    # Reset all associated sheets total_response_count to zero to trigger refresh of sheet answer coverage
    def reset_sheet_total_response_count
      self.sheets.update_all( total_response_count: 0 )
    end

    def set_slug
      if self.slug.blank? and self.publicly_available?
        self.slug = self.name.parameterize
        if self.valid?
          self.save
        else
          self.slug += "-#{SecureRandom.hex(8)}"
          self.save
        end
      end
    end

end
