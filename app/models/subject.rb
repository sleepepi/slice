# frozen_string_literal: true

# Represents a subject and the associated sheets, adverse events,
# randomizations, and events.
class Subject < ApplicationRecord
  # Concerns
  include Deletable
  include Evaluatable
  include Searchable
  include Squishable

  squish :subject_code

  # Scopes
  scope :with_project, ->(arg) { where(project_id: arg) }
  scope :randomized, -> { where.not(randomizations_count: 0) }
  scope :unrandomized, -> { where(randomizations_count: 0) }
  scope :open_aes, -> { joins(:adverse_events).where(adverse_events: { closed: false }).distinct }
  scope :closed_aes, -> { joins(:adverse_events).where(adverse_events: { closed: true }).distinct }
  scope :any_aes, -> { joins(:adverse_events).distinct }

  # Validations
  validates :project_id, :subject_code, :site_id, presence: true
  validates :subject_code, uniqueness: { case_sensitive: false, scope: [:deleted, :project_id] }
  validate :validate_subject_format

  def name
    subject_code
  end

  # Relationships
  belongs_to :project
  belongs_to :site
  belongs_to :user, optional: true
  has_many :adverse_events, -> { current }
  has_many :ae_adverse_events, -> { current }
  has_many :randomizations, -> { current }
  has_many :sheets, -> { current }
  has_many :subject_events, -> { joins(:event).order(:event_date, "events.position") }

  # Methods

  def medications
    []
  end

  def self.searchable_attributes
    %w(subject_code)
  end

  def blinded_comments(current_user)
    Comment.current.where(sheet_id: blinded_sheets(current_user).select(:id))
  end

  def blinded_comments_count(current_user)
    blinded_sheets(current_user).sum(:comments_count)
  end

  def editable_by?(current_user)
    current_user.all_subjects.where(id: id).count == 1
  end

  def self.first_or_create_with_defaults(project, subject_code, site_name, user, default_site)
    # (1) Find existing subject...
    subject = project.subjects.find_by(subject_code: subject_code)
    return subject if subject
    # (2) if not found slot into site by subject code and set proper site or use fallback
    site = project.sites.find_by(name: site_name)
    default_site = site if site
    subject = project.subjects.where(subject_code: subject_code)
                     .first_or_create(user_id: user.id, site_id: default_site.id)
    subject
  end

  def new_digest_subject?(sheet_ids)
    sheets.where.not(id: sheet_ids).count.zero?
  end

  def uploaded_files(current_user)
    sheet_variable_scope = SheetVariable.where(sheet: blinded_sheets(current_user)).includes(:variable, :sheet)
    grid_scope = Grid.where(sheet_variable: sheet_variable_scope).includes(:variable, sheet_variable: :sheet)
    (sheet_variable_scope.with_files.to_a + grid_scope.with_files.to_a).sort_by(&:created_at).reverse
  end

  def uploaded_files_count(current_user)
    update_uploaded_file_counts! if unblinded_uploaded_files_count.nil? || blinded_uploaded_files_count.nil?
    if project.unblinded?(current_user)
      unblinded_uploaded_files_count
    else
      blinded_uploaded_files_count
    end
  end

  def has_value?(variable, value)
    domain_option = variable.domain_options.find_by(value: value)
    if domain_option
      sheets.joins(:sheet_variables).where(sheet_variables: { variable_id: variable.id, domain_option: domain_option }).count >= 1
    else
      sheets.joins(:sheet_variables).where(sheet_variables: { variable_id: variable.id, value: value }).count >= 1
    end
  end

  def blinded_sheets(current_user)
    current_user.all_viewable_sheets.where(subject_id: id).where(missing: false)
  end

  def blinded_subject_events(current_user)
    subject_events.where(event_id: current_user.all_viewable_events.select(:id))
  end

  def last_created_or_edited_sheet(current_user)
    edited_sheet = last_edited_sheet(current_user)
    created_sheet = last_created_sheet(current_user)
    if edited_sheet && created_sheet
      if edited_sheet.last_edited_at > created_sheet.created_at
        edited_sheet
      else
        created_sheet
      end
    elsif edited_sheet
      edited_sheet
    elsif created_sheet
      created_sheet
    end
  end

  def last_edited_sheet(current_user)
    blinded_sheets(current_user).where.not(last_edited_at: nil).order(last_edited_at: :desc).first
  end

  def last_created_sheet(current_user)
    blinded_sheets(current_user).order(created_at: :desc).first
  end

  def validate_subject_format
    if user && site && site.subject_regex.present? && site.subject_regex !~ subject_code
      errors[:subject_code] << "must be in the following format: #{site.regex_string}"
    end
  end

  def stratification_factors(randomization_scheme)
    result = {}
    randomization_scheme.stratification_factors_with_calculation.each do |sf|
      calculation = expand_calculation(sf.calculation)
      result[sf.id.to_s] = exec_js_context.eval(calculation)
    end
    result
  end

  def stratification_factors_for_params(randomization_scheme)
    result = {}
    randomization_scheme.stratification_factors_with_calculation.each do |sf|
      calculation = expand_calculation(sf.calculation)
      sfo_value = exec_js_context.eval(calculation)
      option = sf.stratification_factor_options.find_by(value: sfo_value)
      result[sf.id.to_s] = option ? option.id : nil
    end
    randomization_scheme.stratification_factors.where(stratifies_by_site: true).each do |sf|
      result[sf.id.to_s] = site_id
    end
    result
  end

  def expand_calculation(calculation)
    calculation.to_s.gsub(/\#{(\d+)}/) { variable_javascript_value($1) }
  end

  def variable_javascript_value(variable_id)
    variable = project.variables.find_by(id: variable_id)
    if variable
      response_for_variable(variable).to_json
    else
      "\#{#{variable_id}}"
    end
  end

  def response_for_variable(variable, event: nil)
    filtered_sheets = \
      if event
        sheets.joins(:subject_event).merge(SubjectEvent.where(event: event)) if event
      else
        sheets
      end
    responses = variable
                .sheet_variables.joins(:sheet).merge(filtered_sheets)
                .pluck_domain_option_value_or_value
    formatter = Formatters.for(variable)
    formatted_responses = formatter.format_array(responses, true).uniq.compact
    formatted_responses.size == 1 ? formatted_responses.first : nil
  end

  def unblinded_not_missing_sheets
    sheets.where(missing: false)
  end

  def blinded_not_missing_sheets
    if project.blinding_enabled?
      sheets.where(missing: false)
            .joins(:design).where(designs: { only_unblinded: false })
            .left_joins(subject_event: :event).where(events: { only_unblinded: [nil, false] })
    else
      unblinded_not_missing_sheets
    end
  end

  def update_uploaded_file_counts!
    update_columns(
      unblinded_uploaded_files_count: unblinded_not_missing_sheets.sum(:uploaded_files_count),
      blinded_uploaded_files_count: blinded_not_missing_sheets.sum(:uploaded_files_count)
    )
  end

  def evaluate?(event: nil, design: nil, variable: nil, value: nil, operator: "=")
    return true if variable.nil? || value.blank?
    scope = sheets
    scope = scope.joins(:subject_event).where(subject_events: { event: event }) if event
    scope = scope.where(design: design) if design
    value_scope = variable.sheet_variables.where(sheet_id: scope.select(:id))
    value_scope = value_scope.where(variable: variable) if variable
    values = value_scope.pluck_domain_option_value_or_value
    count = \
      case operator
      when "<", ">", "<=", ">="
        values.reject(&:blank?).count { |v| v.to_f.send(operator, value.to_f) }
      when "!="
        values.count { |v| v != value }
      else
        values.count { |v| v == value }
      end
    count.positive?
  end
end
