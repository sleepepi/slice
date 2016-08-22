# frozen_string_literal: true

# Provides a framework to layout a series of sections and variables that make
# up a data collection form.
class Design < ApplicationRecord
  mount_uploader :csv_file, SpreadsheetUploader

  serialize :options, Array

  # Callbacks
  after_save :reset_sheet_total_response_count, :set_slug

  QUESTION_TYPES = [
    ['free text', 'string'],
    ['select one answer', 'radio'],
    ['select multiple answers', 'checkbox'],
    ['date', 'date'],
    ['time', 'time'],
    ['number', 'numeric'],
    ['file upload', 'file']
  ]

  # Concerns
  include Searchable, Deletable, Latexable, DateAndTimeParser, Sluggable, Forkable

  attr_writer :questions
  attr_accessor :reimport

  # Scopes
  scope :with_user, -> (arg) { where user_id: arg }
  scope :with_project, -> (arg) { where project_id: arg }

  # Model Validation
  validates :name, :user_id, :project_id, presence: true
  validates :name, uniqueness: { scope: [:deleted, :project_id] }
  validates :slug, uniqueness: { scope: :deleted }, allow_blank: true
  validates :csv_file, presence: true, if: :reimport?

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :category, -> { where deleted: false }
  has_many :sheets, -> { current.joins(:subject).merge(Subject.current) }
  has_many :sections
  belongs_to :updater, class_name: 'User', foreign_key: 'updater_id'
  has_many :event_designs

  has_many :design_options, -> { order :position }
  has_many :variables, through: :design_options

  # Model Methods

  # Shows designs IF
  # Project has Blind module disabled
  # OR Design not set as Only Blinded
  # OR User is Project Owner
  # OR User is Unblinded Project Member
  # OR User is Unblinded Site Member
  def self.blinding_scope(user)
    joins(:project)
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = projects.id and project_users.user_id = #{user.id}")
      .joins("LEFT OUTER JOIN site_users ON site_users.project_id = projects.id and site_users.user_id = #{user.id}")
      .where('projects.blinding_enabled = ? or designs.only_unblinded = ? or projects.user_id = ? or project_users.unblinded = ? or site_users.unblinded = ?', false, false, user.id, true, true)
      .distinct
  end

  def self.order_by_user_name
    joins('LEFT JOIN users ON users.id = designs.user_id')
      .order('users.last_name, users.first_name')
      .select('designs.*, users.last_name, users.first_name')
  end

  def self.order_by_user_name_desc
    joins('LEFT JOIN users ON users.id = designs.user_id')
      .order('users.last_name desc, users.first_name desc')
      .select('designs.*, users.last_name, users.first_name')
  end

  def questions
    @questions || [{ question_name: '', question_type: 'free text' }]
  end

  def create_variables_from_questions!
    questions.reject { |hash| hash[:question_name].blank? }.each_with_index do |question_hash, position|
      name = question_hash[:question_name].to_s.downcase.gsub(/[^a-zA-Z0-9]/, '_').gsub(/^[\d_]/, 'n').gsub(/_{2,}/, '_').gsub(/_$/, '')[0..31].strip
      name = "var_#{Digest::SHA1.hexdigest(Time.zone.now.usec.to_s)[0..27]}" if project.variables.where(name: name).size != 0
      variable_type = (QUESTION_TYPES.collect { |_name, value| value }.include?(question_hash[:question_type]) ? question_hash[:question_type] : 'string')
      variable = project.variables.create(
        name: name,
        display_name: question_hash[:question_name],
        variable_type: variable_type
      )
      design_options.create variable_id: variable.id, position: position unless variable.new_record?
    end
    recalculate_design_option_positions!
  end

  def editable_by?(current_user)
    current_user.all_designs.where(id: id).count == 1
  end

  def options_with_grid_sub_variables
    new_options = []
    design_options.includes(:variable, :section).each do |design_option|
      new_options << design_option
      variable = design_option.variable
      next unless variable && variable.variable_type == 'grid'
      variable.grid_variables.each do |grid_variable|
        new_options << DesignOption.new(variable_id: grid_variable[:variable_id])
      end
    end
    new_options
  end

  def branching_logic(design_option)
    design_option.branching_logic.to_s.gsub(/([a-zA-Z]+[\w]*)/) { |m| variable_replacement($1) }.to_json
  end

  def variable_replacement(variable_name)
    variable = variables.find_by name: variable_name
    if variable && ['radio'].include?(variable.variable_type)
      "$(\"[name='variables[#{variable.id}]']:checked\").val()"
    elsif variable && ['checkbox'].include?(variable.variable_type)
      "$.map($(\"[name='variables[#{variable.id}][]']:checked\"),function(el){return $(el).val();})"
    elsif variable
      "$(\"#variables_#{variable.id}\").val()"
    else
      variable_name
    end
  end

  def main_sections
    design_options.joins(:section).where(sections: { level: 0 })
  end

  def design_options_grouped_by_section
    result = []
    current_section = ['', []]
    design_options.each do |design_option|
      if design_option.section
        result << current_section unless current_section == ['', []]
        current_section = [design_option.section.name, []]
      elsif design_option.variable
        current_section[1] << [design_option.variable.display_name, design_option.variable_id]
      end
    end
    result << current_section unless current_section == ['', []]
    result
  end

  def reorder_sections(section_order, current_user)
    return if section_order.size == 0 || section_order.sort != (0..main_sections.count - 1).to_a
    original_sections = {}

    current_section = nil
    range_start = 0
    section_count = 0
    design_options.each_with_index do |design_option, index|
      section = design_option.section
      if design_option.variable || (section && section.level != 0)
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
      rows += (original_sections[position][0]..original_sections[position][1]).to_a
    end

    reorder_options(rows, current_user)
  end

  def reorder_options(row_order, current_user)
    return if row_order.size == 0 || row_order.sort != (0..design_options.count - 1).to_a
    design_options.each do |design_option|
      design_option.update position: row_order.index(design_option.position)
    end
    update updater_id: current_user.id
    reload
  end

  def latex_partial(partial)
    File.read(File.join('app', 'views', 'designs', 'latex', "_#{partial}.tex.erb"))
  end

  def latex_file_location(current_user)
    jobname = "design_#{id}"
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
    @report_subtitle = report_subtitle
    @report_caption = report_caption
    @percent = percent
    @table_header = table_header
    @table_body = table_body
    @table_footer = table_footer

    jobname = "project_#{@project.id}_design_#{id}_report"
    output_folder = File.join('tmp', 'files', 'tex')
    file_tex = File.join('tmp', 'files', 'tex', jobname + '.tex')

    File.open(file_tex, 'w') do |file|
      file.syswrite(ERB.new(latex_partial('report_new')).result(binding))
    end

    Design.generate_pdf(jobname, output_folder, file_tex)
  end

  def load_variables
    @load_variables ||= begin
      raw_variables = header_row
      raw_variables.reject! { |i| %w(Subject Site).include?(i) }
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
      if csv_file.path
        current_line = 0
        CSV.parse(File.open(csv_file.path, 'r:iso-8859-1:utf-8') { |f| f.read }) do |line|
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
      v = project.variables.find_by_name(name.to_s)
      next if hash[:ignore] == '1' or (not v and not Variable::TYPE_IMPORTABLE.flatten.include?(hash[:variable_type]))
      v = project.variables.create(name: name, display_name: hash[:display_name], variable_type: hash[:variable_type], updater_id: user_id, user_id: user_id) unless v
      new_variables << v
    end

    build_design_options_from_variable_array(new_variables.compact.uniq)

    set_total_rows
  end

  def build_design_options_from_variable_array(variables)
    design_options.delete_all
    variables.each_with_index do |variable, position|
      design_options.create variable_id: variable.id, position: position
    end
  end

  def set_total_rows
    counter = 0
    CSV.parse(File.open(csv_file.path, 'r:iso-8859-1:utf-8') { |f| f.read }, headers: true) { counter += 1 } if csv_file.path
    update total_rows: counter
  end

  def create_sheets!(default_site, current_user, remote_ip)
    unless csv_file.path && default_site
      update total_rows: 0
      return
    end

    update import_started_at: Time.zone.now
    set_total_rows
    counter = 0

    variables_and_column_names = load_variables.collect do |hash|
      variable = project.variables.find_by_name hash[:name]
      column_name = hash[:column_name]
      [variable, column_name]
    end

    CSV.parse(File.open(csv_file.path, 'r:iso-8859-1:utf-8') { |f| f.read }, headers: true) do |line|
      row = line.to_hash.with_indifferent_access
      subject = Subject.first_or_create_with_defaults(project, row['Subject'], row['Site'].to_s, current_user, default_site)
      if subject
        sheet = sheets.where(subject_id: subject.id).first_or_initialize(project_id: project_id, user_id: current_user.id, last_user_id: current_user.id)
        transaction_type = (sheet.new_record? ? 'sheet_create' : 'sheet_update')
        variables_params = {}

        variables_and_column_names.each do |variable, column_name|
          if variable && Variable::TYPE_IMPORTABLE.flatten.include?(variable.variable_type)
            variables_params[variable.id.to_s] = variable.response_to_value(row[column_name].to_s)
          end
        end

        SheetTransaction.save_sheet!(sheet, {}, variables_params, current_user, remote_ip, transaction_type)
      end
      counter += 1
      update(rows_imported: counter) if counter % 25 == 0 || counter == total_rows
    end

    update import_ended_at: Time.zone.now
    notify_user! current_user
  end

  def notify_user!(current_user)
    UserMailer.import_complete(self, current_user).deliver_now if EMAILS_ENABLED
  end

  def insert_new_design_option!(design_option)
    design_options.where.not(id: design_option.id).where('position >= ?', design_option.position).each { |dopt| dopt.update(position: dopt.position + 1) }
    recalculate_design_option_positions!
  end

  def recalculate_design_option_positions!
    design_options.each_with_index { |design_option, index| design_option.update(position: index) }
    reload
  end

  def name_from_csv!
    return unless name.blank? && csv_file.path && csv_file.path.split('/').last
    self.name = csv_file.path.split('/').last.gsub(/csv|\./, '').humanize.capitalize
  end

  def generate_import_in_background(site_id, current_user, remote_ip)
    update rows_imported: 0, total_rows: 1, import_started_at: Time.zone.now, import_ended_at: nil
    fork_process(:generate_import, site_id, current_user, remote_ip)
  end

  def generate_import(site_id, current_user, remote_ip)
    site = project.sites.find_by_id(site_id)
    create_sheets!(site, current_user, remote_ip)
  end

  def reimport?
    reimport == '1'
  end

  private

  # Reset all associated sheets total_response_count to zero to trigger refresh of sheet answer coverage
  def reset_sheet_total_response_count
    sheets.update_all total_response_count: 0
  end

  def set_slug
    return unless slug.blank? && publicly_available?
    self.slug = name.parameterize
    self.slug += "-#{SecureRandom.hex(8)}" unless valid?
    save
  end
end
