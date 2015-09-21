class Design < ActiveRecord::Base
  mount_uploader :csv_file, SpreadsheetUploader

  serialize :options, Array

  # Callbacks
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
  has_many :variables, through: :design_options


  # Model Methods

  def questions
    @questions || [ { question_name: '', question_type: 'free text' } ]
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

  def create_variables_from_questions!
    self.questions.select{|hash| not hash[:question_name].blank?}.each_with_index do |question_hash, position|
      name = question_hash[:question_name].to_s.downcase.gsub(/[^a-zA-Z0-9]/, '_').gsub(/^[\d_]/, 'n').gsub(/_{2,}/, '_').gsub(/_$/, '')[0..31].strip
      name = "var_#{Digest::SHA1.hexdigest(Time.zone.now.usec.to_s)[0..27]}" if self.project.variables.where( name: name ).size != 0
      variable_type = (QUESTION_TYPES.collect{|name,value| value}.include?(question_hash[:question_type]) ? question_hash[:question_type] : 'string')
      variable = self.project.variables.create(
        name: name,
        display_name: question_hash[:question_name],
        variable_type: variable_type
      )
      self.design_options.create variable_id: variable.id, position: position unless variable.new_record?
    end
    self.recalculate_design_option_positions!
  end

  def editable_by?(current_user)
    current_user.all_designs.where(id: self.id).count == 1
  end

  def copyable_attributes
    self.attributes.reject{|key, val| ['id', 'slug', 'user_id', 'deleted', 'created_at', 'updated_at'].include?(key.to_s)}
  end

  def options_with_grid_sub_variables
    new_options = []
    self.design_options.includes(:variable, :section).each do |design_option|
      new_options << design_option
      if variable = design_option.variable and variable.variable_type == 'grid'
        variable.grid_variables.each do |grid_variable|
          new_options << DesignOption.new(variable_id: grid_variable[:variable_id])
        end
      end
    end
    new_options
  end

  def branching_logic(design_option)
    design_option.branching_logic.to_s.gsub(/([a-zA-Z]+[\w]*)/){|m| variable_replacement($1)}.to_json
  end

  def variable_replacement(variable_name)
    variable = self.variables.find_by_name(variable_name)
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

  def main_sections
    self.design_options.joins(:section).where(sections: { sub_section: false })
  end

  # def all_sections
  #   self.options.select{|option| not option[:section_name].blank?}
  # end

  def reportable_variables(variable_types, except_variable_ids)
    design_option_variables = self.design_options.includes(:variable).where.not(variable_id: nil).where.not(variable_id: except_variable_ids).where(variables: { variable_type: variable_types })
    design_option_variables.collect{|design_option| [self.containing_section(design_option.position), design_option.variable.display_name, design_option.variable_id]}
  end

  def grouped_reportable_variables(variable_types, except_variable_ids)
    reportable_variables(variable_types, except_variable_ids).group_by{|a| a[0]}.collect{|section, values| [section, values.collect{|a| [a[1], a[2]]}]}
  end

  def containing_section(position)
    self.design_options.includes(:section).where.not(section_id: nil).where('position < ?', position).pluck("sections.name").last
  end

  def reorder_sections(section_order, current_user)
    return if section_order.size == 0 or section_order.sort != (0..self.main_sections.count - 1).to_a
    original_sections = {}

    current_section = nil
    range_start = 0
    section_count = 0
    self.design_options.each_with_index do |design_option, index|
      if design_option.variable or (section = design_option.section and section.sub_section?)
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
    return if row_order.size == 0 or row_order.sort != (0..self.design_options.count - 1).to_a
    self.design_options.each do |design_option|
      design_option.update position: row_order.index(design_option.position)
    end
    self.update updater_id: current_user.id
    self.reload
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
    new_variables = []
    variable_hashes.each do |name, hash|
      v = self.project.variables.find_by_name(name.to_s)
      next if hash[:ignore] == '1' or (not v and not Variable::TYPE_IMPORTABLE.flatten.include?(hash[:variable_type]))
      v = self.project.variables.create( name: name, display_name: hash[:display_name], variable_type: hash[:variable_type], updater_id: self.id, user_id: self.user_id ) unless v
      new_variables << v
    end

    self.build_design_options_from_variable_array(new_variables.compact.uniq)

    self.set_total_rows
  end

  def build_design_options_from_variable_array(variables)
    self.design_options.delete_all
    variables.each_with_index do |variable, position|
      self.design_options.create variable_id: variable.id, position: position
    end
  end

  def build_design_options_from_json(options, current_user)
    self.design_options.delete_all

    options.each_with_index do |option, position|
      if not option['variable'].blank?
        variable = self.project.create_variable_from_json(option['variable'], current_user)
      elsif not option['section'].blank?
        section = self.sections.create(
          project_id: self.project_id,
          user_id: current_user.id,
          name: option['section']['name'],
          description: option['section']['description'],
          sub_section: option['section']['sub_section']
        )
      end

      self.design_options.create(
        variable_id: (variable ? variable.id : nil),
        section_id: (section ? section.id : nil),
        position: position,
        branching_logic: option['branching_logic'].to_s.strip,
        required: option['required'].to_s.strip
      )
    end

  end

  def set_total_rows
    counter = 0
    CSV.parse( File.open(self.csv_file.path, 'r:iso-8859-1:utf-8'){|f| f.read}, headers: true ){ counter += 1 } if self.csv_file.path
    self.update( total_rows: counter )
  end

  def create_sheets!(default_site, default_status, current_user, remote_ip)
    if self.csv_file.path and default_site
      self.update( import_started_at: Time.zone.now )
      self.set_total_rows
      counter = 0

      variables_and_column_names = self.load_variables.collect do |hash|
        variable = self.project.variables.find_by_name hash[:name]
        column_name = hash[:column_name]
        [variable, column_name]
      end

      CSV.parse( File.open(self.csv_file.path, 'r:iso-8859-1:utf-8'){|f| f.read}, headers: true ) do |line|
        row = line.to_hash.with_indifferent_access
        subject = Subject.first_or_create_with_defaults(self.project, row['Subject'], row['Acrostic'].to_s, current_user, default_site, default_status)
        if subject
          sheet = self.sheets.where( subject_id: subject.id ).first_or_initialize( project_id: self.project_id, user_id: current_user.id, last_user_id: current_user.id )
          transaction_type = (sheet.new_record? ? 'sheet_create' : 'sheet_update')
          variables_params = {}

          variables_and_column_names.each do |variable, column_name|
            if variable and Variable::TYPE_IMPORTABLE.flatten.include?(variable.variable_type)
              variables_params[variable.id.to_s] = row[column_name].to_s
            end
          end

          SheetTransaction.save_sheet!(sheet, {}, variables_params, current_user, remote_ip, transaction_type)
        end
        counter += 1
        self.update( rows_imported: counter ) if counter % 25 == 0 or counter == self.total_rows
      end
    end

    self.update import_ended_at: Time.zone.now
    self.notify_user!(current_user)
  end

  def notify_user!(current_user)
    UserMailer.import_complete(self, current_user).deliver_later if Rails.env.production?
  end

  def insert_new_design_option!(design_option)
    self.design_options.where.not(id: design_option.id).where('position >= ?', design_option.position).each{ |design_option| design_option.update(position: design_option.position + 1) }
    self.recalculate_design_option_positions!
  end

  def recalculate_design_option_positions!
    self.design_options.each_with_index{|design_option, index| design_option.update(position: index)}
    self.reload
  end

  private

    # Reset all associated sheets total_response_count to zero to trigger refresh of sheet answer coverage
    def reset_sheet_total_response_count
      self.sheets.update_all total_response_count: 0
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
