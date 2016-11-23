# frozen_string_literal: true

# Defines a collection of responses to a design for a subject.
class Sheet < ApplicationRecord
  # Concerns
  include Deletable, Latexable, Siteable, Evaluatable, AutoLockable, Forkable

  before_save :check_subject_event_subject_match

  # Scopes
  scope :search, -> (arg) { where('sheets.subject_id in (select subjects.id from subjects where subjects.deleted = ? and LOWER(subjects.subject_code) LIKE ?) or design_id in (select designs.id from designs where designs.deleted = ? and LOWER(designs.name) LIKE ?)', false, arg.to_s.downcase.gsub(/^| |$/, '%'), false, arg.to_s.downcase.gsub(/^| |$/, '%')).references(:designs) }
  scope :sheet_before, -> (*args) { where('sheets.created_at < ?', (args.first + 1.day).at_midnight) }
  scope :sheet_after, -> (*args) { where('sheets.created_at >= ?', args.first.at_midnight) }

  scope :with_variable_response, -> (*args) { where('sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response = ?)', args.first, args[1]) }
  scope :with_checkbox_variable_response, -> (*args) { where('sheets.id IN (select responses.sheet_id from responses where responses.variable_id = ? and responses.value = ? )', args.first, args[1]) }

  # These don't include blank codes
  scope :with_variable_response_after, -> (*args) { where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response >= ? and sheet_variables.response != '')", args.first, args[1]) }
  scope :with_variable_response_before, -> (*args) { where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response <= ? and sheet_variables.response != '')", args.first, args[1]) }

  # # Includes entered values, or entered missing values
  # scope :with_any_variable_response, lambda { |*args| where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response IS NOT NULL and sheet_variables.response != '')", args.first) }
  # Includes only entered values (that are not marked as missing)
  scope :with_any_variable_response_not_missing_code, -> (*args) { where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response IS NOT NULL and sheet_variables.response != '' and sheet_variables.response NOT IN (?))", args.first, (args.first.missing_codes.blank? ? [''] : args.first.missing_codes)) }
  scope :with_checkbox_any_variable_response_not_missing_code, -> (*args) { where("sheets.id IN (select responses.sheet_id from responses where responses.variable_id = ? and responses.value IS NOT NULL and responses.value != '' and responses.value NOT IN (?))", args.first, (args.first.missing_codes.blank? ? [''] : args.first.missing_codes)) }
  # Include blank, unknown, or values entered as missing
  scope :with_response_unknown_or_missing, -> (*args) { where("sheets.id NOT IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.response IS NOT NULL and sheet_variables.response != '' and sheet_variables.response NOT IN (?))", args.first, (args.first.missing_codes.blank? ? [''] : args.first.missing_codes)) }

  # Model Validation
  validates :design_id, :project_id, :subject_id, presence: true
  validates :authentication_token, uniqueness: true, allow_nil: true

  # Model Relationships
  belongs_to :user
  belongs_to :last_user, class_name: 'User'
  belongs_to :design
  belongs_to :project
  belongs_to :subject
  belongs_to :subject_event
  belongs_to :adverse_event, -> { current }, touch: true
  has_many :sheet_variables
  has_many :responses
  has_many :variables, -> { current }, through: :sheet_variables
  has_many :comments, -> { current.order(created_at: :desc) }
  has_many :sheet_transactions, -> { order(id: :desc) }
  has_many :sheet_transaction_audits
  has_many :sheet_unlock_requests, -> { current.order(created_at: :desc) }
  has_many :status_checks
  has_many :failed_checks, -> { runnable.where(status_checks: { failed: true }) },
           through: :status_checks, source: :check

  # Model Methods
  delegate :description, to: :design

  def name
    design ? design.name : 'No Design'
  end

  def event_at
    created_at
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
  # TODO: This can be cleaned up using the new Search module along with operators.
  def self.with_stratum(current_user, stratum_id, stratum_value, operator, stratum_start_date = nil, stratum_end_date = nil)
    stratum_variable = if stratum_id == 'design'
                         Variable.design(0) # 0 project?...
                       elsif stratum_id == 'site' || stratum_id.nil?
                         Variable.site(0) # 0 project?...
                       elsif stratum_id == 'sheet_date'
                         Variable.sheet_date(0) # 0 project?...
                       else
                         Variable.find_by_id(stratum_id)
                       end

    if stratum_variable && stratum_variable.variable_type == 'design'
      where(design_id: stratum_value)
    elsif stratum_variable && stratum_variable.variable_type == 'site'
      with_site(stratum_value)
    elsif stratum_variable && operator == 'any' && !(%w(sheet_date).include?(stratum_variable.variable_type))
      filter_variable(stratum_variable, current_user, 'any')
    elsif stratum_variable && %w(sheet_date date).include?(stratum_variable.variable_type) && !%w(blank missing).include?(operator)
      sheet_after_variable(stratum_variable, stratum_start_date).sheet_before_variable(stratum_variable, stratum_end_date)
    elsif stratum_value.present? # Ex: stratum_id: variables(:gender).id, stratum_value: 'f'
      if stratum_variable.variable_type == 'file'
        # TODO: This may be able to target a specific file.
        filter_variable(stratum_variable, current_user, 'any')
      elsif stratum_variable.variable_type == 'checkbox'
        with_checkbox_variable_response(stratum_id, stratum_value)
      else
        with_variable_response(stratum_id, stratum_value)
      end
    elsif stratum_variable && operator == 'blank'
      filter_variable(stratum_variable, current_user, operator)
    else # Ex: stratum_id: variables(:gender).id, stratum_value: nil
      filter_variable(stratum_variable, current_user, 'missing')
    end
  end

  # TODO: Temporary rewrite to use Search instead of sheet scopes
  def self.filter_variable(variable, current_user, operator)
    token = Token.new(key: variable.name, operator: operator)
    Search.run_sheets(
      variable.project,
      current_user,
      current_user.all_viewable_sheets.where(project_id: variable.project.id).where(missing: false),
      token
    ).where(design_id: variable.designs.select(:id))
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

  # Buffers with blank responses for sheets that don't have a sheet_variable for the specific variable
  def self.sheet_responses(variable)
    value_scope = SheetVariable.where(sheet_id: select(:id), variable_id: variable.id)
    responses = if variable.variable_type == 'file'
                  value_scope.pluck(:response_file)
                else
                  value_scope.pluck_domain_option_value_or_response
                end
    responses + [''] * [all.count - responses.size, 0].max
  end

  def self.sheet_responses_for_checkboxes(variable)
    Response.where(sheet_id: select(:id), variable_id: variable.id).pluck_domain_option_value_or_value
  end

  def expanded_branching_logic(branching_logic)
    branching_logic.to_s.gsub(/([a-zA-Z]+[\w]*)/){|m| variable_javascript_value($1)}
  end

  # TODO: Check speed of function using where vs find (caching and memory)
  def variable_javascript_value(variable_name)
    variable = design.variables.find { |v| v.name == variable_name }
    if variable
      sheet_variable = sheet_variables.find { |sv| sv.variable_id == variable.id }
      result = if sheet_variable
                 sheet_variable.get_response(:raw)
               else
                 variable.variable_type == 'checkbox' ? [''] : ''
               end
      result.to_json
    else
      variable_name
    end
  end

  def show_design_option?(branching_logic)
    return true if branching_logic.to_s.strip.blank?
    result = exec_js_context.eval(expanded_branching_logic(branching_logic))
    result == false ? false : true
  rescue
    true
  end

  def grids
    Grid.where(
      sheet_variable_id: sheet_variables.joins(:variable).where(variables: { variable_type: 'grid' }).select(:id)
    )
  end

  # Returns the file path with the relative location
  # - The name of the file as it will appear in the archive
  # - The original file, including the path to find it
  def files
    objects = sheet_variables.with_files + grids.with_files
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
    if variable && %w(site sheet_date).include?(variable.variable_type)
      responses = sheet_scope.includes(:subject).collect { |s| s.subject.site_id } if variable.variable_type == 'site'
      responses = sheet_scope.pluck(:created_at) if variable.variable_type == 'sheet_date'
    else
      responses = (variable ? SheetVariable.where(sheet_id: sheet_scope.select(:id), variable_id: variable.id).pluck_domain_option_value_or_response : [])
    end
    # Convert to integer or float
    variable && variable.variable_type == 'integer' ? responses.map(&:to_i) : responses.map(&:to_f)
  end

  # Computes calculation for a scope of sheet responses
  # Ex: Sheet.array_calculation(Sheet.all, Variable.where(name: 'age'), 'array_mean')
  #     Would return the average of all ages on all sheets that contained age (as a sheet_variable, not as a grid or grid_response)
  def self.array_calculation(sheet_scope, variable, calculation)
    calculation = 'array_count' if calculation.blank?
    number = \
      if calculation == 'array_count'
        # New, to account for sheets that are scoped based on a
        # missing/non-entered value, should be counted as the count of sheets,
        # not the count of responses.
        send(calculation, sheet_scope.pluck(:id))
      else
        send(calculation, array_responses(sheet_scope, variable))
      end

    if calculation != 'array_count' && !number.nil?
      number = \
        if variable.variable_type == 'calculated' && variable.format.present?
          format(variable.format, number) rescue number
        else
          format('%0.02f', number)
        end
    end
    number
  end

  def self.filter_sheet_scope(sheet_scope, filters, current_user)
    (filters || []).each do |filter|
      unless filter[:start_date].is_a?(Date)
        filter[:start_date] = Date.parse(filter[:start_date]) rescue filter[:start_date] = nil
      end
      unless filter[:end_date].is_a?(Date)
        filter[:end_date] = Date.parse(filter[:end_date]) rescue filter[:start_date] = nil
      end
      sheet_scope = sheet_scope.with_stratum(current_user, filter[:variable_id], filter[:value], filter[:operator], filter[:start_date], filter[:end_date])
    end
    sheet_scope
  end

  def self.array_responses_with_filters(sheet_scope, variable, filters, current_user)
    sheet_scope = filter_sheet_scope(sheet_scope, filters, current_user)
    array_responses(sheet_scope, variable)
  end

  def self.array_calculation_with_filters(sheet_scope, calculator, calculation, filters, current_user)
    if calculator && calculator.statistics? && calculation.blank?
      # Filtering against "Unknown BMI for example, include only missing codes and unknown"
      sheet_scope = sheet_scope.with_response_unknown_or_missing(calculator)
    elsif calculator && calculator.statistics?
      # Filtering against "BMI for example, only include known responses"
      sheet_scope = sheet_scope.with_any_variable_response_not_missing_code(calculator)
    end

    sheet_scope = filter_sheet_scope(sheet_scope, filters, current_user)
    number = (calculator ? array_calculation(sheet_scope, calculator, calculation) : array_count(sheet_scope.pluck(:id)))

    name = (number == nil ? '-' : number)
    number = 0 unless number

    [name, number]
  end

  def non_blank_design_variable_responses
    sheet_variables.not_empty.where(variable_id: design.variables.select(:id)).count
  end

  def total_design_variables
    design.variables.count
  end

  def out_of
    check_response_count_change
    "#{response_count} of #{total_response_count} #{total_response_count == 1 ? 'question' : 'questions'}"
  end

  def compute_percent(rcount, trcount)
    (rcount * 100.0 / trcount).to_i
  rescue
    nil
  end

  def non_hidden_variable_ids
    @non_hidden_variable_ids ||= begin
      variable_ids = []
      design.design_options.includes(:variable).each do |design_option|
        variable = design_option.variable
        if variable && show_design_option?(design_option.branching_logic)
          variable_ids << variable.id
        end
      end
      variable_ids
    end
  end

  def non_hidden_responses
    sheet_variables.not_empty.where(variable_id: non_hidden_variable_ids).count
  end

  def non_hidden_total_responses
    non_hidden_variable_ids.count
  end

  def check_response_count_change
    update_response_count! if total_response_count.nil?
  end

  def update_response_count!
    rcount = non_hidden_responses
    trcount = non_hidden_total_responses
    pcount = compute_percent(rcount, trcount)
    update_columns(
      response_count: rcount,
      total_response_count: trcount,
      percent: pcount
    )
  end

  def coverage
    "coverage-#{(percent.to_i / 10) * 10}"
  end

  def color
    if percent.to_i == 100
      '#337ab7'
    elsif percent.to_i >= 80
      '#5cb85c'
    elsif percent.to_i >= 60
      '#f0ad4e'
    elsif percent.to_i >= 40
      '#f0ad4e'
    elsif percent.to_i >= 1
      '#d9534f'
    else
      '#777777'
    end
  end

  # Who can view/access the design
  def users
    if design.only_unblinded
      project.unblinded_members_for_site(subject.site)
    else
      project.members_for_site(subject.site)
    end
  end

  def project_editors
    if design.only_unblinded
      project.unblinded_project_editors
    else
      project.project_editors
    end
  end

  def set_token
    return if authentication_token.present?
    update authentication_token: SecureRandom.hex(12)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    retry
  end

  # TODO: Launch after subject "update", sheet "update", check "update"...?
  # - [X] After Sheet Create
  # - [X] After Sheet Update
  # - [X] After Sheet Move
  # - [X] After Another Sheet Update
  # - [X] After Subject Randomized
  # - [X] After Subject Unrandomized
  # - [X] After Check Update (Check filter/check filter value) ?
  def reset_checks!
    project.checks.runnable.find_each do |check|
      status_checks.where(check_id: check.id).first_or_create
    end
    status_checks.update_all failed: nil
  end

  def run_pending_checks!
    status_checks.where(failed: nil).find_each do |status_check|
      if status_check.check.sheets.where(id: id).count == 1
        status_check.update failed: true
      else
        status_check.update failed: false
      end
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
