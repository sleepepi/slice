# frozen_string_literal: true

class Subject < ApplicationRecord
  # Concerns
  include Searchable, Deletable, Evaluatable, Squishable, Forkable

  squish :subject_code

  # Scopes
  scope :with_project, -> (arg) { where(project_id: arg) }
  scope :without_design, -> (arg) { where('subjects.id NOT IN (select sheets.subject_id from sheets where sheets.deleted = ? and sheets.design_id IN (?))', false, arg) }
  scope :with_design, -> (arg) { where('subjects.id IN (select sheets.subject_id from sheets where sheets.deleted = ? and sheets.design_id IN (?))', false, arg) }
  scope :without_event, -> (event) { where('subjects.id NOT IN (select subject_events.subject_id from subject_events where subject_events.event_id IN (?))', event) }
  scope :with_event, -> (event) { where('subjects.id IN (select subject_events.subject_id from subject_events where subject_events.event_id IN (?))', event) }
  scope :with_entered_design_on_event, -> (design, event) { where('subjects.id IN (select subject_events.subject_id from subject_events where subject_events.event_id = ? and subject_events.id IN (SELECT sheets.subject_event_id from sheets where sheets.deleted = ? and sheets.missing = ? and sheets.design_id = ? and sheets.subject_event_id IS NOT NULL))', event, false, false, design) }
  scope :with_missing_design_on_event, -> (design, event) { where('subjects.id IN (select subject_events.subject_id from subject_events where subject_events.event_id = ? and subject_events.id IN (SELECT sheets.subject_event_id from sheets where sheets.deleted = ? and sheets.missing = ? and sheets.design_id = ? and sheets.subject_event_id IS NOT NULL))', event, false, true, design) }
  scope :with_unentered_design_on_event, -> (design, event) { where('subjects.id IN (select subject_events.subject_id from subject_events where subject_events.event_id = ? and subject_events.id NOT IN (SELECT sheets.subject_event_id from sheets where sheets.deleted = ? and sheets.design_id = ? and sheets.subject_event_id IS NOT NULL))', event, false, design) }
  scope :without_design_on_event, -> (design, event) { where('subjects.id NOT IN (select subject_events.subject_id from subject_events where subject_events.event_id = ? and subject_events.id IN (SELECT sheets.subject_event_id from sheets where sheets.deleted = ? and sheets.design_id = ?))', event, false, design) }
  scope :randomized, -> { joins(:randomizations).distinct }
  scope :unrandomized, -> { joins('LEFT OUTER JOIN randomizations ON randomizations.subject_id = subjects.id and randomizations.deleted is false').where('randomizations.id IS NULL').distinct }
  scope :open_aes, -> { joins(:adverse_events).where(adverse_events: { closed: false }).distinct }
  scope :closed_aes, -> { joins(:adverse_events).where(adverse_events: { closed: true }).distinct }
  scope :any_aes, -> { joins(:adverse_events).distinct }
  # scope :with_variable, lambda {|variable_id, value| where("subjects.id IN (select sheets.subject_id from sheets where sheets.deleted = ? and sheets.id IN (select sheet_variables.sheet_id from sheet_variables where variable_id = ? and response IN (?)))", false, variable_id, value)}

  # Model Validation
  validates :project_id, :subject_code, :site_id, presence: true
  validates :subject_code, uniqueness: { case_sensitive: false, scope: [:deleted, :project_id] }
  # validates :subject_code, validate_subject_format: { with: -> (s) { s.site.subject_regex }, message: -> (s,value) { "#{self.name} #{value} must be in valid format" } }, if: :site_regex_code?
  validate :validate_subject_format

  def name
    subject_code
  end

  # Model Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :site
  has_many :adverse_events, -> { current }
  has_many :randomizations, -> { current }
  has_many :sheets, -> { current }
  has_many :subject_events, -> { joins(:event).order(:event_date, 'events.position') }

  # Model Methods

  def self.searchable_attributes
    %w(subject_code)
  end

  def blinded_comments(current_user)
    Comment.current.where(sheet_id: blinded_sheets(current_user).select(:id))
  end

  def editable_by?(current_user)
    current_user.all_subjects.where(id: id).count == 1
  end

  def self.first_or_create_with_defaults(project, subject_code, site_name, user, default_site)
    # (1) Find existing subject...
    subject = project.subjects.where(subject_code: subject_code).first
    return subject if subject
    # (2) if not found slot into site by subject code and set proper site or use fallback
    site = project.sites.find_by_name(site_name)
    default_site = site if site

    subject = project.subjects.where(subject_code: subject_code).first_or_create(user_id: user.id, site_id: default_site.id)
    subject
  end

  def new_digest_subject?(sheet_ids)
    sheets.where.not(id: sheet_ids).count == 0
  end

  def uploaded_files(current_user)
    SheetVariable.where(sheet_id: blinded_sheets(current_user).select(:id)).with_files
                 .order(created_at: :desc)
  end

  # TODO: Should this look across grids or responses as well...?
  def has_value?(variable, value)
    domain_option = variable.domain_options.find_by(value: value)
    if domain_option
      sheets.joins(:sheet_variables).where(sheet_variables: { variable_id: variable.id, domain_option: domain_option }).count >= 1
    else
      sheets.joins(:sheet_variables).where(sheet_variables: { variable_id: variable.id, response: value }).count >= 1
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
      errors[:base] << "#{project.subject_code_name_full} must be in the following format: #{site.regex_string}"
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
    calculation.to_s.gsub(/([a-zA-Z]+[\w]*)/) { |v| variable_javascript_value(v) }
  end

  def variable_javascript_value(variable_name)
    variable = project.variables.find_by_name variable_name
    if variable
      response_for_variable(variable)
    else
      variable_name
    end
  end

  def response_for_variable(variable)
    responses = variable
                .sheet_variables.joins(:sheet).merge(sheets)
                .left_outer_joins(:domain_option)
                .pluck('domain_options.value', :response)
                .collect { |value, response| value || response }
    formatter = Formatters.for(variable)
    formatted_responses = formatter.format_array(responses, true).uniq.compact
    result = (formatted_responses.size == 1 ? formatted_responses.first : nil)
    result.to_json
  end

  def reset_checks_in_background!
    fork_process(:reset_checks!)
  end

  def reset_checks!
    sheets.find_each(&:reset_checks!)
    sheets.find_each(&:run_pending_checks!)
  end
end
