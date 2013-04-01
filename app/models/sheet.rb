require 'audited'
require 'audited/adapters/active_record'
# require 'audited/auditor'
# require 'audited/adapters/active_record/audit'

class Sheet < ActiveRecord::Base

  audited
  has_associated_audits

  # Concerns
  include Deletable, Latexable

  # Named Scopes
  scope :search, lambda { |arg| where('subject_id in (select subjects.id from subjects where subjects.deleted = ? and LOWER(subjects.subject_code) LIKE ?) or design_id in (select designs.id from designs where designs.deleted = ? and LOWER(designs.name) LIKE ?)', false, arg.to_s.downcase.gsub(/^| |$/, '%'), false, arg.to_s.downcase.gsub(/^| |$/, '%') ).references(:designs) }
  scope :sheet_before, lambda { |*args| where("sheets.created_at < ?", (args.first+1.day).at_midnight) }
  scope :sheet_after, lambda { |*args| where("sheets.created_at >= ?", args.first.at_midnight) }
  scope :with_user, lambda { |*args| where("sheets.user_id in (?)", args.first) }
  scope :with_project, lambda { |*args| where("sheets.project_id IN (?)", args.first) }
  scope :with_design, lambda { |*args| where("sheets.design_id IN (?)", args.first) }
  scope :with_site, lambda { |*args| where("sheets.subject_id IN (select subjects.id from subjects where subjects.deleted = ? and subjects.site_id IN (?))", false, args.first).references(:subjects) }

  scope :with_variable_response, lambda { |*args| where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response = ?)", args.first, args[1]) }

  # These don't include blank codes
  scope :with_variable_response_after, lambda { |*args| where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response >= ? and sheet_variables.response != '')", args.first, args[1]) }
  scope :with_variable_response_before, lambda { |*args| where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response <= ? and sheet_variables.response != '')", args.first, args[1]) }

  # These include blank or missing responses
  scope :with_variable_response_after_with_blank, lambda { |*args| where("sheets.id NOT IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response < ? and sheet_variables.response != '')", args.first, args[1]) }
  scope :with_variable_response_before_with_blank, lambda { |*args| where("sheets.id NOT IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response > ? and sheet_variables.response != '')", args.first, args[1]) }

  # Only includes blank or unknown values
  scope :without_variable_response, lambda { |*args| where("sheets.id NOT IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response IS NOT NULL and sheet_variables.response != '')", args.first) }
  # Includes entered values, or entered missing values
  scope :with_any_variable_response, lambda { |*args| where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response IS NOT NULL and sheet_variables.response != '')", args.first) }
  # Includes only entered values (that are not marked as missing)
  scope :with_any_variable_response_not_missing_code, lambda { |*args| where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response IS NOT NULL and sheet_variables.response != '' and sheet_variables.response NOT IN (?))", args.first, (args.first.missing_codes.blank? ? [''] : args.first.missing_codes)) }
  # Include blank, unknown, or values entered as missing
  scope :with_response_unknown_or_missing, lambda { |*args| where("sheets.id NOT IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response IS NOT NULL and sheet_variables.response != '' and sheet_variables.response NOT IN (?))", args.first, (args.first.missing_codes.blank? ? [''] : args.first.missing_codes)) }

  scope :with_subject_status, lambda { |*args| where("sheets.subject_id IN (select subjects.id from subjects where subjects.deleted = ? and subjects.status IN (?) )", false, args.first).references(:subjects) }

  scope :order_by_site_name, -> { joins("LEFT JOIN subjects ON subjects.id = sheets.subject_id LEFT JOIN sites ON sites.id = subjects.site_id").order('sites.name') }
  scope :order_by_site_name_desc, -> { joins("LEFT JOIN subjects ON subjects.id = sheets.subject_id LEFT JOIN sites ON sites.id = subjects.site_id").order('sites.name DESC') }

  scope :order_by_design_name, -> { joins("LEFT JOIN designs ON designs.id = sheets.design_id").order('designs.name') }
  scope :order_by_design_name_desc, -> { joins("LEFT JOIN designs ON designs.id = sheets.design_id").order('designs.name DESC') }

  scope :order_by_subject_code, -> { joins("LEFT JOIN subjects ON subjects.id = sheets.subject_id").order('subjects.subject_code') }
  scope :order_by_subject_code_desc, -> { joins("LEFT JOIN subjects ON subjects.id = sheets.subject_id").order('subjects.subject_code DESC') }

  scope :order_by_project_name, -> { joins("LEFT JOIN projects ON projects.id = sheets.project_id").order('projects.name') }
  scope :order_by_project_name_desc, -> { joins("LEFT JOIN projects ON projects.id = sheets.project_id").order('projects.name DESC') }

  scope :order_by_user_name, -> { joins("LEFT JOIN users ON users.id = sheets.user_id").order('users.last_name, users.first_name') }
  scope :order_by_user_name_desc, -> { joins("LEFT JOIN users ON users.id = sheets.user_id").order('users.last_name DESC, users.first_name DESC') }

  # Model Validation
  validates_presence_of :design_id, :project_id, :subject_id, :user_id, :last_user_id
  validates_uniqueness_of :authentication_token, allow_nil: true

  # Model Relationships
  belongs_to :user
  belongs_to :last_user, class_name: "User"
  belongs_to :last_viewed_by, class_name: "User"
  belongs_to :design
  belongs_to :project
  belongs_to :subject
  has_many :sheet_variables
  has_many :variables, -> { where deleted: false }, through: :sheet_variables
  has_many :sheet_emails, -> { where deleted: false }
  has_many :comments, -> { where deleted: false }, order: 'created_at desc'

  # Model Methods
  def self.last_entry
    sheet_ids = self.select('DISTINCT ON (subject_id) *').order('subject_id, created_at DESC').pluck(:id)
    self.where(id: sheet_ids)
  end

  def self.first_entry
    sheet_ids = self.select('DISTINCT ON (subject_id) *').order('subject_id, created_at ASC').pluck(:id)
    self.where(id: sheet_ids)
  end

  def send_external_email!(current_user, email, authentication_token = SecureRandom.hex(32))
    begin
      self.update_attributes authentication_token: authentication_token if self.authentication_token.blank?
      # UserMailer.sheet_completion_request(self, email).deliver if Rails.env.production?
      mail = UserMailer.sheet_completion_request(self, email)
      mail.deliver if Rails.env.production?

      sheet_email = self.sheet_emails.create(email_body: mail.html_part.body.decoded, email_cc: (mail.cc || []).join(','), email_pdf_file: nil, email_subject: mail.subject, email_to: (mail.to || []).join(','), user_id: current_user.id)
    rescue => e
      Rails.logger.info "-----------------------"
      Rails.logger.info "Unable to send_external_email! for Sheet #{self.id} due to colliding authentication_token: #{authentication_token}."
      Rails.logger.info "#{e}"
      Rails.logger.info "-----------------------"
    end
  end

  def all_audits
    Audited::Adapters::ActiveRecord::Audit.reorder("created_at DESC").where(["(auditable_type = 'Sheet' and auditable_id = ?) or (associated_type = 'Sheet' and associated_id = ?) or (associated_type = 'SheetVariable' and associated_id IN (?))", self.id, self.id, self.sheet_variables.collect{|sv| sv.id}])
  end

  def audit_show!(current_user)
    self.update_attributes(last_viewed_by_id: current_user.id, last_viewed_at: Time.now)
  end

  def last_emailed_at
    self.sheet_emails.order('created_at desc').pluck(:created_at).first
  end

  def name
    self.design.name
  end

  def description
    self.design.description
  end

  def self.latex_partial(partial)
    File.read(File.join('app', 'views', 'sheets', 'latex', "_#{partial}.tex.erb"))
  end

  def self.latex_file_location(sheets, current_user)
    jobname = (sheets.size == 1 ? "sheet_#{sheets.first.id}" : "sheets_#{Time.now.strftime("%Y%m%d_%H%M%S")}")
    output_folder = File.join('tmp', 'files', 'tex')
    file_tex = File.join('tmp', 'files', 'tex', jobname + '.tex')

    File.open(file_tex, 'w') do |file|
      file.syswrite(ERB.new(latex_partial('header')).result(binding))
      sheets.each do |sheet|
        @sheet = sheet # Needed by Binding
        file.syswrite(ERB.new(latex_partial('body')).result(binding))
      end
      file.syswrite(ERB.new(latex_partial('footer')).result(binding))
    end

    generate_pdf(jobname, output_folder, file_tex)
  end

  # This returns the maximum size of any grid.
  # Ex: A Sheet has two grid variables on it, one with 3 rows, and the other with 2.
  #     This function would return 3. This number is used to combine grids on similar rows in the sheet grids xls export
  def max_grids_position
    self.sheet_variables.size > 0 ? self.sheet_variables.collect(&:max_grids_position).max : -1
  end

  def email_subject_template(current_user)
    return "#{self.project.name} #{self.name} Receipt: #{self.subject.subject_code}" if self.design.email_subject_template.to_s.strip.blank?
    result = ''
    result = self.design.email_subject_template.to_s.gsub(/\$\((.*?)\)(\.name|\.label|\.value)?/){|m| variable_replacement($1,$2)}
    result = result.gsub(/\#\(subject\)(\.acrostic)?/){|m| subject_replacement($1)}
    result = result.gsub(/\#\(site\)/){|m| site_replacement($1)}
    result = result.gsub(/\#\(project\)/){|m| project_replacement($1)}
    result = result.gsub(/\#\(design\)/){|m| design_replacement($1)}
    result = result.gsub(/\#\(user\)(\.email)?/){|m| user_replacement($1, current_user)}
    result
  end

  def email_body_template(current_user)
    result = ''
    result = self.design.email_template.to_s.gsub(/\$\((.*?)\)(\.name|\.label|\.value)?/){|m| variable_replacement($1,$2)}
    result = result.gsub(/\#\(subject\)(\.acrostic)?/){|m| subject_replacement($1)}
    result = result.gsub(/\#\(site\)/){|m| site_replacement($1)}
    result = result.gsub(/\#\(project\)/){|m| project_replacement($1)}
    result = result.gsub(/\#\(design\)/){|m| design_replacement($1)}
    result = result.gsub(/\#\(user\)(\.email)?/){|m| user_replacement($1, current_user)}
    result
  end

  def variable_replacement(variable_name, display_name)
    variable = self.variables.find_by_name(variable_name)
    if variable and display_name.blank?
      variable.response_name(self)
    elsif variable and display_name == '.name'
      variable.display_name
    elsif variable and display_name == '.label'
      variable.response_label(self)
    elsif variable and display_name == '.value'
      variable.response_raw(self)
    else
      ''
    end
  end

  def subject_replacement(property)
    result = ''
    result = if property.blank?
      self.subject.subject_code
    elsif property == '.acrostic'
      self.subject.acrostic.to_s
    end
    result
  end

  def user_replacement(property, current_user)
    result = ''
    result = if property.blank?
      current_user.name
    elsif property == '.email'
      current_user.email
    end
    result
  end

  def site_replacement(property)
    self.subject.site.name
  end

  def project_replacement(property)
    self.project.name
  end

  def design_replacement(property)
    self.design.name
  end

  # stratum can be nil (grouping on site) or a variable (grouping on the variable responses)
  def self.with_stratum(stratum_id, stratum_value, stratum_start_date = nil, stratum_end_date = nil)
    stratum_variable = if stratum_id == 'site' or stratum_id == nil
      Variable.site(0) # 0 project?...
    elsif stratum_id == 'sheet_date'
      Variable.sheet_date(0) # 0 project?...
    else
      Variable.find_by_id(stratum_id)
    end

    if stratum_variable and stratum_value == ':any' and not ['site', 'sheet_date', 'subject_status'].include?(stratum_variable.variable_type)
      self.with_any_variable_response_not_missing_code(stratum_variable)
    elsif stratum_variable and stratum_variable.variable_type == 'site'
      self.with_site(stratum_value)
    elsif stratum_variable and ['sheet_date', 'date'].include?(stratum_variable.variable_type) and stratum_value != ':missing'
      self.sheet_after_variable(stratum_variable, stratum_start_date).sheet_before_variable(stratum_variable, stratum_end_date)
    elsif not stratum_value.blank? and stratum_value != ':missing' # Ex: stratum_id: variables(:gender).id, stratum_value: 'f'
      self.with_variable_response(stratum_id, stratum_value)
    else # Ex: stratum_id: variables(:gender).id, stratum_value: nil
      self.without_variable_response(stratum_id)
    end
  end

  def self.sheet_after_variable(variable, date)
    if variable and variable.variable_type == 'date'
      self.with_variable_response_after(variable, date)
    else
      self.sheet_after(date)
    end
  end

  def self.sheet_before_variable(variable, date)
    if variable and variable.variable_type == 'date'
      self.with_variable_response_before(variable, date)
    else
      self.sheet_before(date)
    end
  end

  def self.sheet_after_variable_with_blank(variable, date)
    if variable and variable.variable_type == 'date'
      self.with_variable_response_after_with_blank(variable, date)
    else
      self.sheet_after(date)
    end
  end

  def self.sheet_before_variable_with_blank(variable, date)
    if variable and variable.variable_type == 'date'
      self.with_variable_response_before_with_blank(variable, date)
    else
      self.sheet_before(date)
    end
  end

  def self.sheet_responses(variable)
    self.all.collect{|sheet| sheet.sheet_variables.where(variable_id: variable.id).pluck(:response)}.flatten
  end

  def expanded_branching_logic(branching_logic)
    branching_logic.to_s.gsub(/([a-zA-Z]+[\w]*)/){|m| variable_javascript_value($1)}
  end

  def variable_javascript_value(variable_name)
    variable = self.design.pure_variables.find_by_name(variable_name)
    result = if variable
      variable.response_raw(self).to_json
    else
      variable_name
    end
  end

  # Since showing and hiding variables is done client side by JavaScript,
  # the corresponding action should also apply when printing out the variable
  # in a PDF document. Since PDF documents don't run JavaScript, the solution
  # presented uses a JavaScript evaluator to evaluate the branching logic.

  def exec_js_context
    @exec_js_context ||= begin
      # Compiled CoffeeScript from designs.js.coffee
      index_of = "var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };"
      intersection_function = "this.intersection = function(a, b) { var value, _i, _len, _ref, _results; if (a.length > b.length) { _ref = [b, a], a = _ref[0], b = _ref[1]; } _results = []; for (_i = 0, _len = a.length; _i < _len; _i++) { value = a[_i]; if (__indexOf.call(b, value) >= 0) { _results.push(value); } } return _results; };"
      overlap_function = "this.overlap = function(a, b, c) { if (c == null) { c = 1; } return intersection(a, b).length >= c; };"
      ExecJS.compile(index_of + intersection_function + overlap_function)
    end
  end

  def show_variable?(branching_logic)
    return true if branching_logic.to_s.strip.blank?

    begin
      exec_js_context.eval expanded_branching_logic(branching_logic)
    rescue => e
      true
    end
  end

  # def show_variable?(branching_logic)
  #   return true if branching_logic.to_s.strip.blank?

  #   # Compiled CoffeeScript from designs.js.coffee
  #   index_of = "var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };"
  #   intersection_function = "this.intersection = function(a, b) { var value, _i, _len, _ref, _results; if (a.length > b.length) { _ref = [b, a], a = _ref[0], b = _ref[1]; } _results = []; for (_i = 0, _len = a.length; _i < _len; _i++) { value = a[_i]; if (__indexOf.call(b, value) >= 0) { _results.push(value); } } return _results; };"
  #   overlap_function = "this.overlap = function(a, b, c) { if (c == null) { c = 1; } return intersection(a, b).length >= c; };"

  #   begin
  #     context = ExecJS.compile(index_of + intersection_function + overlap_function)
  #     context.eval expanded_branching_logic(branching_logic)
  #   rescue => e
  #     true
  #   end
  # end




  def grids
    Grid.where(sheet_variable_id: self.sheet_variables.with_variable_type(['grid']).pluck(:id))
  end

  # Returns the file path with the relative location
  # - The name of the file as it will appear in the archive
  # - The original file, including the path to find it
  def files
    all_files = []
    (self.sheet_variables.with_variable_type(['file']) + self.grids.with_variable_type(['file'])).each do |object|
      if object.response_file.size > 0
        all_files << ["sheet_#{self.id}#{"/#{object.sheet_variable.variable.name}" if object.kind_of?(Grid)}/#{object.variable.name}#{"/#{object.position}" if object.respond_to?('position')}/#{object.response_file.to_s.split('/').last}", object.response_file.path]
      end
    end
    all_files
  end

  def self.array_mean(array)
    return nil if array.size == 0
    array.inject(:+).to_f / array.size
  end

  def self.array_sample_variance(array)
    m = self.array_mean(array)
    sum = array.inject(0){|accum, i| accum +(i-m)**2 }
    sum / (array.length - 1).to_f
  end

  def self.array_standard_deviation(array)
    return nil if array.size < 2
    return Math.sqrt(self.array_sample_variance(array))
  end

  def self.array_median(array)
    return nil if array.size == 0
    array = array.sort!
    len = array.size
    len % 2 == 1 ? array[len/2] : (array[len/2 - 1] + array[len/2]).to_f / 2
  end

  def self.array_max(array)
    array.max #|| 0
  end

  def self.array_min(array)
    array.min #|| 0
  end

  def self.array_count(array)
    size = array.size
    size = nil if size == 0
    size
  end

  def self.array_responses(sheet_scope, variable)
    responses = []
    if variable and ['site', 'sheet_date', 'subject_status'].include?(variable.variable_type)
      responses = sheet_scope.includes(:subject).collect{|s| s.subject.site_id } if variable.variable_type == 'site'
      responses = sheet_scope.pluck(:created_at) if variable.variable_type == 'sheet_date'
      responses = sheet_scope.includes(:subject).collect{|s| s.subject.status } if variable.variable_type == 'subject_status'
    else
      responses = (variable ? SheetVariable.where(sheet_id: sheet_scope.pluck(:id), variable_id: variable.id).pluck(:response) : [])
    end
    # Convert to integer or float
    variable && variable.variable_type == 'integer' ? responses.map(&:to_i) : responses.map(&:to_f)
  end

  # Computes calculation for a scope of sheet responses
  # Ex: Sheet.array_calculation(Sheet.all, Variable.where(name: 'age'), 'array_mean')
  #     Would return the average of all ages on all sheets that contained age (as a sheet_variable, not as a grid or grid_response)
  def self.array_calculation(sheet_scope, variable, calculation)
    number = if calculation.blank? or calculation == 'array_count'
      # New, to account for sheets that are scoped based on a missing/non-entered value, should be counted as the count of sheets, not the count of responses.
      self.array_count(sheet_scope.pluck(:id))
    else
      self.send((calculation.blank? ? 'array_count' : calculation), self.array_responses(sheet_scope, variable))
    end

    unless (calculation.blank? or calculation == 'array_count') or number == nil
      if variable.variable_type == 'calculated' and not variable.format.blank?
        number = variable.format % number rescue number
      else
        number = "%0.02f" % number
      end
    end
    number
  end

  def self.filter_sheet_scope(sheet_scope, filters)
    (filters || []).each do |filter|
      unless filter[:start_date].kind_of?(Date)
        filter[:start_date] = Date.parse(filter[:start_date]) rescue filter[:start_date] = nil
      end
      unless filter[:end_date].kind_of?(Date)
        filter[:end_date] = Date.parse(filter[:end_date]) rescue filter[:start_date] = nil
      end
      sheet_scope = sheet_scope.with_stratum(filter[:variable_id], filter[:value], filter[:start_date], filter[:end_date])
    end
    sheet_scope
  end

  def self.array_responses_with_filters(sheet_scope, variable, filters)
    sheet_scope = filter_sheet_scope(sheet_scope, filters)
    array_responses(sheet_scope, variable)
  end

  def self.array_calculation_with_filters(sheet_scope, calculator, calculation, filters)
    if calculator and calculator.has_statistics? and calculation.blank?
      # Filtering against "Unknown BMI for example, include only missing codes and unknown"
      sheet_scope = sheet_scope.with_response_unknown_or_missing(calculator)
    elsif calculator and calculator.has_statistics?
      # Filtering against "BMI for example, only include known responses"
      sheet_scope = sheet_scope.with_any_variable_response_not_missing_code(calculator)
    end

    sheet_scope = filter_sheet_scope(sheet_scope, filters)
    number = (calculator ? self.array_calculation(sheet_scope, calculator, calculation) : self.array_count(sheet_scope.pluck(:id)))

    name = (number == nil ? '-' : number)

    [name, number]
  end

  # Returns out of the design responses how many are not blank.
  def non_blank_design_variable_responses
    @non_blank_design_variable_responses ||= begin
      non_blank_sheet_variable_ids = self.sheet_variables.collect{|sv| sv.empty_or_not}.compact
      SheetVariable.where(variable_id: self.design.variable_ids).where(id: non_blank_sheet_variable_ids).count
    end
  end

  def total_design_variables
    self.design.variable_ids.count
  end

  def out_of
    check_response_count_change
    "#{self.response_count} of #{self.total_response_count} #{self.total_response_count == 1 ? 'question' : 'questions' }"
  end

  def percent
    check_response_count_change
    (self.response_count * 100.0 / self.total_response_count).to_i rescue 0
  end

  def check_response_count_change
    if self.total_design_variables != self.total_response_count
      self.update_column :response_count, self.non_blank_design_variable_responses
      self.update_column :total_response_count, self.total_design_variables
    end
  end

  def coverage
    if percent == 100
      'complete'
    elsif percent >= 80
      'green'
    elsif percent >= 60
      'yellow'
    elsif percent >= 40
      'orange'
    elsif percent >= 1
      'red'
    else
      'blank'
    end
  end

  def color
    if percent == 100
      '#39B419'
    elsif percent >= 80
      '#9AD425'
    elsif percent >= 60
      '#D7C623'
    elsif percent >= 40
      '#CE7421'
    elsif percent >= 1
      '#D13E15'
    else
      '#6F6F6F'
    end
  end

  protected

  def self.latex_safe(mystring)
    self.new.latex_safe(mystring)
  end

end
