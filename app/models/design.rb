class Design < ActiveRecord::Base
  attr_accessible :description, :name, :options, :option_tokens, :project_id, :email_template, :email_subject_template, :updater_id, :study_date_name

  serialize :options, Array

  before_save :check_option_validations

  # Concerns
  include Searchable, Deletable, Latexable

  # Named Scopes
  scope :with_user, lambda { |*args| { conditions: ['designs.user_id IN (?)', args.first] } }
  scope :with_project, lambda { |*args| { conditions: ['designs.project_id IN (?)', args.first] } }

  scope :order_by_project_name, lambda { |*args| { joins: "LEFT JOIN projects ON projects.id = designs.project_id", order: 'projects.name' } }
  scope :order_by_project_name_desc, lambda { |*args| { joins: "LEFT JOIN projects ON projects.id = designs.project_id", order: 'projects.name DESC' } }

  scope :order_by_user_name, lambda { |*args| { joins: "LEFT JOIN users ON users.id = designs.user_id", order: 'users.last_name, users.first_name' } }
  scope :order_by_user_name_desc, lambda { |*args| { joins: "LEFT JOIN users ON users.id = designs.user_id", order: 'users.last_name DESC, users.first_name DESC' } }

  # Model Validation
  validates_presence_of :name, :user_id, :project_id
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_many :sheets, conditions: { deleted: false }
  belongs_to :updater, class_name: 'User', foreign_key: 'updater_id'

  # Model Methods

  def batch_sheets!(current_user, site, date, emails)
    new_sheets = []
    ignored_sheets = 0
    emails.each do |email|
      short_email = email
      match = email.match(/<(.*?)>/)
      if match and not match[1].strip.blank?
        short_email = match[1].strip.downcase
        email = email.gsub("<#{match[1]}>", "").strip
      end
      subject = site.subjects.find_by_email(short_email) unless short_email.blank?
      subject = site.subjects.find_or_create_by_project_id_and_subject_code(site.project_id, email, { user_id: current_user.id, status: 'valid', email: short_email }) unless subject
      Rails.logger.debug "#{site.project_id}, #{date}, #{subject.id}, #{self.id}, #{current_user.id}"
      sheet = site.project.sheets.find_or_create_by_study_date_and_subject_id_and_design_id(date, subject.id, self.id, { user_id: current_user.id, last_user_id: current_user.id }) if subject
      sheet.send_external_email!(current_user, short_email) if sheet and not sheet.new_record?
      if sheet and not sheet.new_record?
        new_sheets << sheet
      else
        ignored_sheets += 1
      end
    end
    # new_sheets
    [new_sheets.count, ignored_sheets]
  end

  def study_date_name_full
    self.study_date_name.to_s.strip.blank? ? 'Study Date' : self.study_date_name.to_s.strip
  end

  def name_with_project
    "#{self.name} - #{self.project.name}"
  end

  def editable_by?(current_user)
    current_user.all_designs.pluck(:id).include?(self.id)
  end

  def copyable_attributes
    self.attributes.reject{|key, val| ['id', 'user_id', 'deleted', 'created_at', 'updated_at'].include?(key.to_s)}
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

  def options_page(page_number = 1)
    current_page = 1
    options_subset = []
    self.options.each do |option|
      current_page += 1 if option[:break_before] == '1'
      options_subset << option if current_page == page_number
    end
    options_subset
  end

  def total_pages
    @total_pages ||= begin
      self.options.select{|option| option[:break_before] == '1'}.count + 1
    end
  end

  def option_tokens=(tokens)
    self.options = []
    tokens.each_pair do |key, option_hash|
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
                          branching_logic: option_hash[:branching_logic].to_s.strip,
                          break_before: option_hash[:break_before]
                        }
      end
    end
  end

  def branching_logic_section(section_id)
    self.options.select{|item| item[:section_id].to_s == section_id.to_s }.collect{|item| item[:branching_logic].to_s.gsub(/([a-zA-Z]+[\w]*)/){|m| variable_replacement($1)}}.join(' ').to_json
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

  def sections
    self.options.select{|option| not option[:section_name].blank?}
  end

  def section_names
    @section_names ||= begin
      self.sections.collect{|option| option[:section_name]}
    end
  end

  # ActiveRecord...
  def pure_variables
    Variable.current.where(id: variable_ids)
  end

  # Array...
  def variables
    pure_variables.sort!{ |a, b| variable_ids.index(a.id) <=> variable_ids.index(b.id) }
  end

  def reportable_variables(variable_types)
    self.pure_variables.where(variable_type: variable_types).sort!{ |a, b| variable_ids.index(a.id) <=> variable_ids.index(b.id) }.collect{|v| [self.containing_section(variable_ids.index(v.id)), v.display_name, v.id]}
  end

  def grouped_reportable_variables(variable_types)
    reportable_variables(variable_types).group_by{|a| a[0]}.collect{|section, values| [section, values.collect{|a| [a[1], a[2]]}]}
  end

  def containing_section(location)
    self.options[0..location].select{|option| not option[:section_name].blank?}.collect{|option| option[:section_name]}.last
  end

  # sections = ["section_0","section_2","section_1"]
  def reorder_sections(section_positions, current_user)
    new_sections = section_positions.collect{|a| a.gsub('section_', '').to_i}
    return if new_sections.size == 0 or new_sections.sort != (0..self.section_names.size - 1).to_a
    original_sections = {}

    current_section = nil
    range_start = 0
    section_count = 0
    self.options.each_with_index do |option, index|
      if option[:section_name].blank?
        original_sections[current_section] = [range_start, index]
      else
        current_section = section_count
        section_count += 1
        range_start = index
        original_sections[current_section] = [range_start, index]
      end
    end

    rows = original_sections[nil].blank? ? [] : (original_sections[nil][0]..original_sections[nil][1]).to_a

    new_sections.each do |position|
      rows = rows + (original_sections[position][0]..original_sections[position][1]).to_a
    end

    self.reorder(rows.collect{|i| "option_#{i}"}, current_user)
  end

  def reorder(rows, current_user)
    new_rows = rows.collect{|a| a.gsub('option_', '').to_i}
    return if new_rows.size == 0 or new_rows.sort != (0..self.options.size - 1).to_a

    original_options = self.options
    new_options = []

    new_rows.each_with_index do |row, new_location|
      old_location = row
      new_options << original_options[old_location]
    end

    # Only change if the options match up
    if new_options.size == original_options.size
      self.update_attributes updater_id: current_user.id, options: new_options
      self.reload
    end
  end

  def latex_file_location(current_user)
    # @design = self
    jobname = "design_#{self.id}"
    root_folder = FileUtils.pwd
    output_folder = File.join(root_folder, 'tmp', 'files', 'tex')
    template_folder = File.join(root_folder, 'app', 'views', 'designs')
    file_template = File.join(template_folder, 'print.tex.erb')
    file_tex = File.join(root_folder, 'tmp', 'files', 'tex', jobname + '.tex')
    file_in = File.new(file_template, "r")
    file_out = File.new(file_tex, "w")
    template = ERB.new(file_in.sysread(File.size(file_in)))
    file_out.syswrite(template.result(binding))
    file_in.close()
    file_out.close()

    # Run twice to allow LaTeX to compile correctly (page numbers, etc)
    `#{LATEX_LOCATION} -interaction=nonstopmode --jobname=#{jobname} --output-directory=#{output_folder} #{file_tex}`
    `#{LATEX_LOCATION} -interaction=nonstopmode --jobname=#{jobname} --output-directory=#{output_folder} #{file_tex}`

    # Rails.logger.debug "----------------\n"
    # Rails.logger.debug "#{LATEX_LOCATION} -interaction=nonstopmode --jobname=#{jobname} --output-directory=#{output_folder} #{file_tex}"

    file_pdf_location = File.join('tmp', 'files', 'tex', "#{jobname}.pdf")
  end

end
