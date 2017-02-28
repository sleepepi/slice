# frozen_string_literal: true

# Defines a collection of responses to a design for a subject.
class Sheet < ApplicationRecord
  ORDERS = {
    'site' => 'sites.name',
    'site desc' => 'sites.name desc',
    'design' => 'designs.name',
    'design desc' => 'designs.name desc',
    'created_by' => 'users.last_name, users.first_name',
    'created_by desc' => 'users.last_name desc nulls last, users.first_name desc nulls last',
    'subject' => 'subjects.subject_code',
    'subject desc' => 'subjects.subject_code desc',
    'percent' => 'sheets.percent',
    'percent desc' => 'sheets.percent desc nulls last',
    'created' => 'sheets.created_at',
    'created desc' => 'sheets.created_at desc',
    'edited' => 'sheets.last_edited_at',
    'edited desc' => 'sheets.last_edited_at desc nulls last'
  }
  DEFAULT_ORDER = 'sheets.last_edited_at desc nulls last'

  # Concerns
  include Deletable, Latexable, Siteable, Evaluatable, AutoLockable, Forkable, Coverageable

  before_save :check_subject_event_subject_match

  # Scopes
  scope :search, -> (arg) { where('sheets.subject_id in (select subjects.id from subjects where subjects.deleted = ? and LOWER(subjects.subject_code) LIKE ?) or design_id in (select designs.id from designs where designs.deleted = ? and LOWER(designs.name) LIKE ?)', false, arg.to_s.downcase.gsub(/^| |$/, '%'), false, arg.to_s.downcase.gsub(/^| |$/, '%')).references(:designs) }
  scope :sheet_before, -> (*args) { where('sheets.created_at < ?', (args.first + 1.day).at_midnight) }
  scope :sheet_after, -> (*args) { where('sheets.created_at >= ?', args.first.at_midnight) }

  # These don't include blank codes
  scope :with_variable_response_after, -> (*args) { where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.value >= ? and sheet_variables.value != '')", args.first, args[1]) }
  scope :with_variable_response_before, -> (*args) { where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.value <= ? and sheet_variables.value != '')", args.first, args[1]) }

  # # Includes entered values, or entered missing values
  # scope :with_any_variable_response, lambda { |*args| where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.value IS NOT NULL and sheet_variables.value != '')", args.first) }
  # Includes only entered values (that are not marked as missing)
  scope :with_any_variable_response_not_missing_code, -> (*args) { where("sheets.id IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.value IS NOT NULL and sheet_variables.value != '' and sheet_variables.value NOT IN (?))", args.first, (args.first.missing_codes.blank? ? [''] : args.first.missing_codes)) }
  scope :with_checkbox_any_variable_response_not_missing_code, -> (*args) { where("sheets.id IN (select responses.sheet_id from responses where responses.variable_id = ? and responses.value IS NOT NULL and responses.value != '' and responses.value NOT IN (?))", args.first, (args.first.missing_codes.blank? ? [''] : args.first.missing_codes)) }
  # Include blank, unknown, or values entered as missing
  scope :with_response_unknown_or_missing, -> (*args) { where("sheets.id NOT IN (select sheet_variables.sheet_id from sheet_variables where sheet_variables.variable_id = ? and sheet_variables.value IS NOT NULL and sheet_variables.value != '' and sheet_variables.value NOT IN (?))", args.first, (args.first.missing_codes.blank? ? [''] : args.first.missing_codes)) }

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
  def self.with_stratum(current_user, variable, value, operator, stratum_start_date = nil, stratum_end_date = nil)
    if variable.variable_type == 'design'
      where(design_id: value)
    elsif variable.variable_type == 'site'
      with_site(value)
    elsif operator == 'any' && !%w(sheet_date).include?(variable.variable_type)
      filter_variable(variable, current_user, 'any')
    elsif %w(sheet_date date).include?(variable.variable_type) && !%w(blank missing).include?(operator)
      sheet_after_variable(variable, stratum_start_date).sheet_before_variable(variable, stratum_end_date)
    elsif value.present? # Ex: variable: variables(:gender), value: 'f'
      if variable.variable_type == 'file'
        # TODO: This may be able to target a specific file.
        filter_variable(variable, current_user, 'any')
      elsif variable.variable_type == 'checkbox'
        filter_variable(variable, current_user, '=', value: value)
      else
        filter_variable(variable, current_user, '=', value: value)
      end
    elsif operator == 'blank'
      filter_variable(variable, current_user, operator)
    else # Ex: variable: variables(:gender), value: nil
      filter_variable(variable, current_user, 'missing')
    end
  end

  # TODO: Temporary rewrite to use Search instead of sheet scopes
  def self.filter_variable(variable, current_user, operator, value: nil)
    token = Token.new(key: variable.name, operator: operator, variable: variable, value: value)
    Search.run_sheets(
      variable.project,
      current_user,
      current_user.all_viewable_sheets.where(project_id: variable.project.id).where(missing: false),
      token
    ).where(design_id: variable.designs.select(:id))
  end

  def self.sheet_after_variable(variable, date)
    if variable.variable_type == 'date'
      with_variable_response_after(variable, date)
    else
      sheet_after(date)
    end
  end

  def self.sheet_before_variable(variable, date)
    if variable.variable_type == 'date'
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
                  value_scope.pluck_domain_option_value_or_value
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

  def self.array_responses(sheet_scope, variable)
    responses = []
    if variable && %w(site sheet_date).include?(variable.variable_type)
      responses = sheet_scope.includes(:subject).collect { |s| s.subject.site_id } if variable.variable_type == 'site'
      responses = sheet_scope.pluck(:created_at) if variable.variable_type == 'sheet_date'
    else
      responses = (variable ? SheetVariable.where(sheet_id: sheet_scope.select(:id), variable_id: variable.id).pluck_domain_option_value_or_value : [])
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
        Statistics.send(calculation, sheet_scope.pluck(:id))
      else
        Statistics.send(calculation, array_responses(sheet_scope, variable))
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
      sheet_scope = sheet_scope.with_stratum(current_user, filter[:variable], filter[:value], filter[:operator], filter[:start_date], filter[:end_date])
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
    number = if calculator
               array_calculation(sheet_scope, calculator, calculation)
             else
               Statistics.array_count(sheet_scope.pluck(:id))
             end
    name = (number.nil? ? '-' : number)
    number = 0 unless number
    [name, number]
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

  def check_subject_event_subject_match
    self.subject_event_id = nil if subject_event && subject_event.subject != subject
  end
end
