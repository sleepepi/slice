class Sheet < ActiveRecord::Base
  # Concerns
  include Deletable, Latexable, DoubleDataEntry, Siteable

  before_save :check_subject_event_subject_match

  # Named Scopes
  scope :search, -> (arg) { where('subject_id in (select subjects.id from subjects where subjects.deleted = ? and LOWER(subjects.subject_code) LIKE ?) or design_id in (select designs.id from designs where designs.deleted = ? and LOWER(designs.name) LIKE ?)', false, arg.to_s.downcase.gsub(/^| |$/, '%'), false, arg.to_s.downcase.gsub(/^| |$/, '%')).references(:designs) }
  scope :sheet_before, -> (*args) { where('sheets.created_at < ?', (args.first + 1.day).at_midnight) }
  scope :sheet_after, -> (*args) { where('sheets.created_at >= ?', args.first.at_midnight) }
  scope :with_user, -> (*args) { where('sheets.user_id in (?)', args.first) }
  scope :with_project, -> (*args) { where('sheets.project_id IN (?)', args.first) }
  scope :with_design, -> (*args) { where('sheets.design_id IN (?)', args.first) }

  scope :with_variable_response, -> (*args) { where('sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response = ?)', args.first, args[1]) }
  scope :with_checkbox_variable_response, -> (*args) { where('sheets.id IN (select responses.sheet_id from responses where responses.variable_id = ? and responses.value = ? )', args.first, args[1]) }

  # These don't include blank codes
  scope :with_variable_response_after, -> (*args) { where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response >= ? and sheet_variables.response != '')", args.first, args[1]) }
  scope :with_variable_response_before, -> (*args) { where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response <= ? and sheet_variables.response != '')", args.first, args[1]) }

  # These include blank or missing responses
  scope :with_variable_response_after_with_blank, -> (*args) { where("sheets.id NOT IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response < ? and sheet_variables.response != '')", args.first, args[1]) }
  scope :with_variable_response_before_with_blank, -> (*args) { where("sheets.id NOT IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response > ? and sheet_variables.response != '')", args.first, args[1]) }

  # Only includes blank or unknown values
  scope :without_variable_response, -> (*args) { where("sheets.id NOT IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response IS NOT NULL and sheet_variables.response != '')", args.first) }
  scope :without_checkbox_variable_response, -> (*args) { where("sheets.id NOT IN (select responses.sheet_id from responses where responses.variable_id = ? and responses.value IS NOT NULL and responses.value != '')", args.first) }

  # # Includes entered values, or entered missing values
  # scope :with_any_variable_response, lambda { |*args| where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response IS NOT NULL and sheet_variables.response != '')", args.first) }
  # Includes only entered values (that are not marked as missing)
  scope :with_any_variable_response_not_missing_code, -> (*args) { where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response IS NOT NULL and sheet_variables.response != '' and sheet_variables.response NOT IN (?))", args.first, (args.first.missing_codes.blank? ? [''] : args.first.missing_codes)) }
  scope :with_checkbox_any_variable_response_not_missing_code, -> (*args) { where("sheets.id IN (select responses.sheet_id from responses where responses.variable_id = ? and responses.value IS NOT NULL and responses.value != '' and responses.value NOT IN (?))", args.first, (args.first.missing_codes.blank? ? [''] : args.first.missing_codes)) }
  # Include blank, unknown, or values entered as missing
  scope :with_response_unknown_or_missing, -> (*args) { where("sheets.id NOT IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response IS NOT NULL and sheet_variables.response != '' and sheet_variables.response NOT IN (?))", args.first, (args.first.missing_codes.blank? ? [''] : args.first.missing_codes)) }

  scope :with_subject_status, -> (*args) { where('sheets.subject_id IN (select subjects.id from subjects where subjects.deleted = ? and subjects.status IN (?) )', false, args.first).references(:subjects) }

  # Model Validation
  validates :design_id, :project_id, :subject_id, presence: true
  validates :authentication_token, uniqueness: true, allow_nil: true

  # Model Relationships
  belongs_to :user
  belongs_to :last_user, class_name: 'User'
  belongs_to :first_locked_by, class_name: 'User'
  belongs_to :design
  belongs_to :project
  belongs_to :subject
  belongs_to :event
  belongs_to :subject_schedule
  belongs_to :subject_event
  belongs_to :adverse_event, -> { where deleted: false }, touch: true
  has_many :sheet_variables
  has_many :responses
  has_many :variables, -> { where deleted: false }, through: :sheet_variables
  has_many :sheet_emails, -> { where deleted: false }
  has_many :comments, -> { where(deleted: false).order(created_at: :desc) }
  has_many :sheet_transactions, -> { order(id: :desc) }
  has_many :sheet_transaction_audits

  # Model Methods

  delegate :name, to: :design
  delegate :description, to: :design

  def event_at
    created_at
  end

  def contributors
    sheet_transactions.select(&:user).collect { |st| st.user.name }.uniq.join(', ')
  end

  def editable_by?(current_user)
    current_user.all_sheets.where(id: id).count == 1
  end

  def recently_created?
    (last_edited_at.nil? || ((last_edited_at - created_at) / 1.minute).to_i == 0)
  end

  def self.latex_partial(partial)
    File.read(File.join('app', 'views', 'sheets', 'latex', "_#{partial}.tex.erb"))
  end

  def self.latex_file_location(sheets, current_user)
    jobname = (sheets.size == 1 ? "sheet_#{sheets.first.id}" : "sheets_#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}")
    output_folder = File.join('tmp', 'files', 'tex')
    file_tex = File.join('tmp', 'files', 'tex', jobname + '.tex')

    File.open(file_tex, 'w') do |file|
      file.syswrite(ERB.new(latex_partial('header')).result(binding))
      sheets.each do |sheet|
        @sheet = sheet # Needed by Binding
        file.syswrite(ERB.new(latex_partial('body')).result(binding))
        file.syswrite(ERB.new(latex_partial('audits')).result(binding))
      end
      file.syswrite(ERB.new(latex_partial('footer')).result(binding))
    end

    generate_pdf(jobname, output_folder, file_tex)
  end

  # This returns the maximum size of any grid.
  # Ex: A Sheet has two grid variables on it, one with 3 rows, and the other with 1.
  #     This function would return 2 (position is zero-indexed, so [0,1,2]). This
  #     number is used to combine grids on similar rows in the sheet grids export
  def max_grids_position
    Grid.where(sheet_variable_id: sheet_variables.select(:id)).pluck(:position).max || -1
  end

  # stratum can be nil (grouping on site) or a variable (grouping on the variable responses)
  def self.with_stratum(stratum_id, stratum_value, stratum_start_date = nil, stratum_end_date = nil)
    stratum_variable = if stratum_id == 'design'
                         Variable.design(0) # 0 project?...
                       elsif stratum_id == 'site' || stratum_id.nil?
                         Variable.site(0) # 0 project?...
                       elsif stratum_id == 'sheet_date'
                         Variable.sheet_date(0) # 0 project?...
                       else
                         Variable.find_by_id(stratum_id)
                       end

    if stratum_variable and stratum_value == ':any' and not %w(site sheet_date subject_status design).include?(stratum_variable.variable_type)
      if stratum_variable.variable_type == 'checkbox'
        with_checkbox_any_variable_response_not_missing_code(stratum_variable)
      else
        with_any_variable_response_not_missing_code(stratum_variable)
      end
    elsif stratum_variable && stratum_variable.variable_type == 'design'
      with_design(stratum_value)
    elsif stratum_variable && stratum_variable.variable_type == 'site'
      with_site(stratum_value)
    elsif stratum_variable && %w(sheet_date date).include?(stratum_variable.variable_type) && stratum_value != ':missing'
      sheet_after_variable(stratum_variable, stratum_start_date).sheet_before_variable(stratum_variable, stratum_end_date)
    elsif not stratum_value.blank? and stratum_value != ':missing' # Ex: stratum_id: variables(:gender).id, stratum_value: 'f'
      if stratum_variable.variable_type == 'checkbox'
        with_checkbox_variable_response(stratum_id, stratum_value)
      else
        with_variable_response(stratum_id, stratum_value)
      end
    else # Ex: stratum_id: variables(:gender).id, stratum_value: nil
      if stratum_variable.variable_type == 'checkbox'
        without_checkbox_variable_response(stratum_id)
      else
        without_variable_response(stratum_id)
      end
    end
  end

  def self.sheet_after_variable(variable, date)
    if variable && variable.variable_type == 'date'
      with_variable_response_after(variable, date)
    else
      sheet_after(date)
    end
  end

  def self.sheet_before_variable(variable, date)
    if variable && variable.variable_type == 'date'
      with_variable_response_before(variable, date)
    else
      sheet_before(date)
    end
  end

  # def self.sheet_after_variable_with_blank(variable, date)
  #   if variable and variable.variable_type == 'date'
  #     self.with_variable_response_after_with_blank(variable, date)
  #   else
  #     self.sheet_after(date)
  #   end
  # end

  # def self.sheet_before_variable_with_blank(variable, date)
  #   if variable and variable.variable_type == 'date'
  #     self.with_variable_response_before_with_blank(variable, date)
  #   else
  #     self.sheet_before(date)
  #   end
  # end

  # Buffers with blank responses for sheets that don't have a sheet_variable for the specific variable
  def self.sheet_responses(variable)
    responses = SheetVariable.where(sheet_id: self.all.select(:id), variable_id: variable.id).pluck(:response)
    responses + ['']*([self.all.count - responses.size, 0].max)
  end

  def self.sheet_responses_for_checkboxes(variable)
    Response.where(sheet_id: self.all.select(:id), variable_id: variable.id).pluck(:value)
  end

  def expanded_branching_logic(branching_logic)
    branching_logic.to_s.gsub(/([a-zA-Z]+[\w]*)/){|m| variable_javascript_value($1)}
  end

  # TODO Check speed of function using where vs select (caching and memory)
  def variable_javascript_value(variable_name)
    variable = self.design.variables.select{|v| v.name == variable_name}.first
    result = if variable
      result = if sheet_variable = self.sheet_variables.select{|sv| sv.variable_id == variable.id}.first
        sheet_variable.get_response(:raw)
      else
        variable.variable_type == 'checkbox' ? [''] : ''
      end
      result.to_json
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
      index_of = 'var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };'
      intersection_function = 'this.intersection = function(a, b) { var value, _i, _len, _ref, _results; if (a.length > b.length) { _ref = [b, a], a = _ref[0], b = _ref[1]; } _results = []; for (_i = 0, _len = a.length; _i < _len; _i++) { value = a[_i]; if (__indexOf.call(b, value) >= 0) { _results.push(value); } } return _results; };'
      overlap_function = 'this.overlap = function(a, b, c) { if (c == null) { c = 1; } return intersection(a, b).length >= c; };'
      ExecJS.compile(index_of + intersection_function + overlap_function)
    end
  end

  def show_variable?(branching_logic)
    return true if branching_logic.to_s.strip.blank?
    result = exec_js_context.eval(expanded_branching_logic(branching_logic))
    result == false ? false : true
  rescue
    true
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
    Grid.where(sheet_variable_id: sheet_variables.with_variable_type(['grid']).select(:id))
  end

  # Returns the file path with the relative location
  # - The name of the file as it will appear in the archive
  # - The original file, including the path to find it
  def files
    objects = sheet_variables.with_variable_type(['file']) + grids.with_variable_type(['file'])
    objects.select { |o| o.response_file.size > 0 }.collect do |object|
      ["FILES/sheet_#{id}#{"/#{object.sheet_variable.variable.name}" if object.is_a?(Grid)}/#{object.variable.name}#{"/#{object.position}" if object.respond_to?('position')}/#{object.response_file.to_s.split('/').last}", object.response_file.path]
    end
  end

  def self.array_mean(array)
    return nil if array.size == 0
    array.inject(:+).to_f / array.size
  end

  def self.array_sample_variance(array)
    m = array_mean(array)
    sum = array.inject(0) { |a, e| a + (e - m)**2 }
    sum / (array.length - 1).to_f
  end

  def self.array_standard_deviation(array)
    return nil if array.size < 2
    Math.sqrt(array_sample_variance(array))
  end

  def self.array_median(array)
    return nil if array.size == 0
    array = array.sort
    len = array.size
    if len.odd?
      array[len / 2]
    else
      (array[len / 2 - 1] + array[len / 2]).to_f / 2
    end
  end

  def self.array_max(array)
    array.max
  end

  def self.array_min(array)
    array.min
  end

  def self.array_count(array)
    size = array.size
    size = nil if size == 0
    size
  end

  def self.array_responses(sheet_scope, variable)
    responses = []
    if variable && %w(site sheet_date subject_status).include?(variable.variable_type)
      responses = sheet_scope.includes(:subject).collect { |s| s.subject.site_id } if variable.variable_type == 'site'
      responses = sheet_scope.pluck(:created_at) if variable.variable_type == 'sheet_date'
      responses = sheet_scope.includes(:subject).collect { |s| s.subject.status } if variable.variable_type == 'subject_status'
    else
      responses = (variable ? SheetVariable.where(sheet_id: sheet_scope.select(:id), variable_id: variable.id).pluck(:response) : [])
    end
    # Convert to integer or float
    variable && variable.variable_type == 'integer' ? responses.map(&:to_i) : responses.map(&:to_f)
  end

  # Computes calculation for a scope of sheet responses
  # Ex: Sheet.array_calculation(Sheet.all, Variable.where(name: 'age'), 'array_mean')
  #     Would return the average of all ages on all sheets that contained age (as a sheet_variable, not as a grid or grid_response)
  def self.array_calculation(sheet_scope, variable, calculation)
    calculation = 'array_count' if calculation.blank?
    number = if calculation == 'array_count'
               # New, to account for sheets that are scoped based on a missing/non-entered value, should be counted as the count of sheets, not the count of responses.
               send(calculation, sheet_scope.pluck(:id))
             else
               send(calculation, array_responses(sheet_scope, variable))
             end

    if calculation != 'array_count' && !number.nil?
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
      unless filter[:start_date].is_a?(Date)
        filter[:start_date] = Date.parse(filter[:start_date]) rescue filter[:start_date] = nil
      end
      unless filter[:end_date].is_a?(Date)
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
    if calculator && calculator.has_statistics? && calculation.blank?
      # Filtering against "Unknown BMI for example, include only missing codes and unknown"
      sheet_scope = sheet_scope.with_response_unknown_or_missing(calculator)
    elsif calculator && calculator.has_statistics?
      # Filtering against "BMI for example, only include known responses"
      sheet_scope = sheet_scope.with_any_variable_response_not_missing_code(calculator)
    end

    sheet_scope = filter_sheet_scope(sheet_scope, filters)
    number = (calculator ? array_calculation(sheet_scope, calculator, calculation) : array_count(sheet_scope.pluck(:id)))

    name = (number == nil ? '-' : number)
    number = 0 unless number

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
    design.variables.count
  end

  def out_of
    check_response_count_change
    "#{response_count} of #{total_response_count} #{total_response_count == 1 ? 'question' : 'questions'}"
  end

  def percent
    check_response_count_change
    begin
      (response_count * 100.0 / total_response_count).to_i
    rescue
      0
    end
  end

  def non_hidden_variable_ids
    @non_hidden_variable_ids ||= begin
      variable_ids = []
      design.design_options.includes(:variable).each do |design_option|
        variable = design_option.variable
        if variable && show_variable?(design_option.branching_logic)
          variable_ids << variable.id
        end
      end
      variable_ids
    end
  end

  def non_hidden_responses
    non_blank_sheet_variable_ids = sheet_variables.collect(&:empty_or_not).compact
    SheetVariable.where(variable_id: non_hidden_variable_ids).where(id: non_blank_sheet_variable_ids).count
  end

  def non_hidden_total_responses
    non_hidden_variable_ids.count
  end

  def check_response_count_change
    update_response_count! if total_response_count.to_i == 0
  end

  def update_response_count!
    update_column :response_count, non_hidden_responses
    update_column :total_response_count, non_hidden_total_responses
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
      '#8feb75' # '#39B419'
    elsif percent >= 80
      '#c9f56a' # '#9AD425'
    elsif percent >= 60
      '#f5e662' # '#D7C623'
    elsif percent >= 40
      '#f5b073' # '#CE7421'
    elsif percent >= 1
      '#ff8563' # '#D13E15'
    else
      '#999999' # '#6F6F6F'
    end
  end

  def get_response(variable, raw_format = :raw)
    sheet_variable = sheet_variables.find_by_variable_id(variable.id)
    unless sheet_variable
      return (variable.variable_type == 'checkbox' ? [''] : '')
    end
    sheet_variable.get_response(raw_format)
  end

  # Who can view/access the design
  def users
    if design.only_unblinded
      project.unblinded_members_for_site(subject.site)
    else
      project.members_for_site(subject.site)
    end
  end

  protected

  def self.latex_safe(mystring)
    new.latex_safe(mystring)
  end

  def check_subject_event_subject_match
    self.subject_event_id = nil if subject_event && subject_event.subject != subject
  end
end
