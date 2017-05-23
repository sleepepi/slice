# frozen_string_literal: true

# Defines how data is captured, displayed, and exported.
class Variable < ApplicationRecord
  # Constants
  TYPE = %w(
    calculated
    checkbox
    date
    dropdown
    file
    grid
    imperial_height
    imperial_weight
    integer
    numeric
    radio
    string
    text
    time_of_day
    time_duration
    signature
  ).sort.collect { |i| [i, i] }

  TYPE_IMPORTABLE = %w(
    string text integer numeric date time_of_day
  ).sort.collect { |i| [i, i] }

  TYPE_DOMAIN = %w(dropdown checkbox radio integer numeric)

  DISPLAY_LAYOUTS = [
    ['Question Inline with Answer', 'visible'],
    ['Question Above Answer ', 'gone']
  ]

  ALIGNMENT = [
    %w(Horizontal horizontal),
    %w(Vertical vertical),
    %w(Scale scale)
  ]

  TIME_OF_DAY_FORMATS = [
    ['24-Hour', '24hour'],
    ['12-Hour AM/PM [AM]', '12hour'],
    ['12-Hour AM/PM [PM]', '12hour-pm']
  ]

  TIME_DURATION_FORMATS = [
    ['HH:MM:SS', 'hh:mm:ss'],
    ['HH:MM', 'hh:mm'],
    ['MM:SS', 'mm:ss']
  ]

  # Callbacks
  after_save :update_domain_values!

  attr_accessor :questions, :grid_tokens

  # Concerns
  include Searchable, Deletable, DateAndTimeParser, Calculable, Squishable

  squish :name, :display_name, :field_note, :prepend, :append, :units, :format

  # Scopes
  scope :with_user, ->(arg) { where(user_id: arg) }

  # Validations
  validates :name, :display_name, :variable_type, :project_id, presence: true
  validates :name, format: { with: /\A[a-z]\w*\Z/i }, length: { maximum: 32 }, exclusion: { in: %w(new edit create update destroy overlap null) }
  validates :name, uniqueness: { scope: [:deleted, :project_id] }
  validates :time_of_day_format, inclusion: { in: TIME_OF_DAY_FORMATS.collect(&:second) }
  validates :time_duration_format, inclusion: { in: TIME_DURATION_FORMATS.collect(&:second) }

  # Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :domain, counter_cache: true
  has_many :sheet_variables
  has_many :grids
  has_many :responses
  belongs_to :updater, class_name: 'User', foreign_key: 'updater_id'
  has_many :design_options, -> { order :position }
  has_many :designs, through: :design_options
  has_many :child_grid_variables, -> { order('position nulls last') },
           class_name: 'GridVariable', source: :child_variable,
           foreign_key: :parent_variable_id
  has_many :child_variables, through: :child_grid_variables
  has_many :parent_grid_variables, class_name: 'GridVariable', source: :parent_variable, foreign_key: :child_variable_id
  has_many :parent_variables, through: :parent_grid_variables

  # Methods
  def self.searchable_attributes
    %w(name description display_name)
  end

  def create_variables_from_questions!
    return unless variable_type == 'grid' && questions.present?
    questions.select { |hash| hash[:question_name].present? }.each_with_index do |question_hash, index|
      question_hash = question_hash.symbolize_keys
      name = question_hash[:question_name].to_s.downcase
                                          .gsub(/[^a-zA-Z0-9]/, '_')
                                          .gsub(/^[\d_]/, 'n')
                                          .gsub(/_{2,}/, '_')
                                          .gsub(/_$/, '')[0..31].strip
      name = "var_#{SecureRandom.hex(12)}" if project.variables.where(name: name).size != 0
      new_variable_type = if Design::QUESTION_TYPES.collect(&:second).include?(question_hash[:question_type])
                            question_hash[:question_type]
                          else
                            'string'
                          end
      params = {
        variable_type: new_variable_type,
        name: name,
        display_name: question_hash[:question_name]
      }
      variable = project.variables.create(params)
      next if variable.new_record?
      child_grid_variables.create(
        project_id: project_id,
        child_variable_id: variable.id,
        position: index
      )
    end
  end

  def domain_options
    domain ? domain.domain_options : DomainOption.none
  end

  def domain_options_with_user(response, current_user)
    unarchived_domain_options = domain_options.where('domain_options.archived = ? OR domain_options.value IN (?)', false, response)
    return unarchived_domain_options unless current_user
    site_ids = current_user.all_editable_sites.where(project_id: project_id).select(:id)
    unarchived_domain_options.where(site_id: site_ids).or(unarchived_domain_options.where(site_id: nil))
  end

  def autocomplete_array
    autocomplete_values.to_s.split(/[\n\r]/).collect(&:strip).reject(&:blank?)
  end

  def uses_scale?
    %w(radio checkbox).include?(variable_type) && alignment == 'scale'
  end

  # Use inherited designs to include grid variables
  def inherited_designs
    design_options = DesignOption.where(variable_id: id).or(
      DesignOption.where(variable_id: parent_variables.select(:id))
    )
    project.designs.where(id: design_options.select(:design_id)).order(:name)
  end

  def editable_by?(current_user)
    current_user.all_variables.where(id: id).count == 1
  end

  def copyable_attributes
    attributes.reject { |key, _val| %w(id user_id deleted created_at updated_at).include?(key.to_s) }
  end

  # Includes responses, grids, and sheet_variables
  def captured_values
    @captured_values ||= begin
      if variable_type == 'file'
        (sheet_variables.pluck(:response_file) +
          grids.pluck(:response_file)).uniq.reject(&:blank?)
      else
        (sheet_variables.pluck_domain_option_value_or_value +
          grids.pluck_domain_option_value_or_value +
          responses.pluck_domain_option_value_or_value).uniq.reject(&:blank?)
      end
    end
  end

  def range_tooltip
    result = ''
    minimum = hard_minimum || soft_minimum
    maximum = hard_maximum || soft_maximum
    with_units = (units.blank? ? '' : " #{units}")
    if !minimum.blank? && !maximum.blank?
      result = "[#{minimum}, #{maximum}]" + with_units
    elsif minimum.blank? && !maximum.blank?
      result = "<= #{maximum}" + with_units
    elsif maximum.blank? && !minimum.blank?
      result = ">= #{minimum}" + with_units
    end
    result
  end

  def update_grid_tokens!
    return if grid_tokens.nil?
    child_grid_variables.delete_all
    grid_tokens.each_with_index do |grid_hash, index|
      next unless grid_hash[:variable_id].strip.to_i > 0
      child_grid_variables.create(
        project_id: project_id,
        child_variable_id: grid_hash[:variable_id].strip.to_i,
        position: index
      )
    end
  end

  def missing_codes
    domain_options.where(missing_code: true).pluck(:value)
  end

  def first_scale_variable?(design)
    return true unless design
    position = design.design_options.pluck(:variable_id).index(id)
    if position && position > 0
      design_option = design.design_options[position - 1]
      previous_variable = design_option.variable
    end
    if previous_variable && previous_variable.uses_scale? && previous_variable.domain_id == domain_id
      return false
    else
      return true
    end
  end

  def last_scale_variable?(design)
    return true unless design
    position = design.design_options.pluck(:variable_id).index(id)
    if position
      design_option = design.design_options[position + 1]
      next_variable = design_option.variable if design_option
    end
    if next_variable && next_variable.uses_scale? && next_variable.domain_id == domain_id
      return false
    else
      return true
    end
  end

  def options_or_autocomplete(include_missing)
    if variable_type == 'string'
      NaturalSort.sort(autocomplete_array.reject(&:blank?).collect { |val| { name: val, value: val } }) + NaturalSort.sort(user_submitted_sheet_variables.collect { |sv| { name: sv.value, value: sv.value, info: 'User Submitted' } }.uniq { |a| a[:value].downcase })
    else
      doscope = \
        if include_missing
          domain_options
        else
          domain_options.where(missing_code: false)
        end
      doscope.collect do |domain_option|
        { name: domain_option.name, value: domain_option.value, missing_code: domain_option.missing_code? ? '1' : '0' }
      end
    end
  end

  # Responses that are user submitted and not on autocomplete list
  def user_submitted_sheet_variables
    sheet_variables.reject { |sv| autocomplete_array.include?(sv.value.to_s.strip) || sv.value.to_s.strip.blank? }
  end

  def formatted_calculation
    readable_calculation.to_s.gsub(/\?|\:/, '<br/>&nbsp;\0<br/>').html_safe
  end

  def statistics?
    %w(integer numeric calculated imperial_height imperial_weight time_of_day time_duration).include?(variable_type)
  end

  def has_domain?
    %w(dropdown checkbox radio integer numeric).include?(variable_type)
  end

  # Captured values are limited to a finite set of options.
  def finite_set_options?
    %w(dropdown checkbox radio).include?(variable_type)
  end

  def report_strata(include_missing, max_strata, hash, sheet_scope)
    strata = base_strata(sheet_scope, include_missing, hash)
    strata << missing_filter if include_missing && !%w(site sheet_date dropdown radio string checkbox).include?(variable_type)
    strata.collect! { |s| s.merge(calculator: self, variable: self) }
    strata.last(max_strata)
  end

  def base_strata(sheet_scope, include_missing, hash)
    if statistics? && hash[:axis] == 'col'
      statistic_filters
    elsif %w(dropdown radio string checkbox).include?(variable_type)
      domain_filters(sheet_scope, include_missing)
    elsif variable_type == 'design'
      design_filters
    elsif variable_type == 'site'
      site_filters
    elsif %w(sheet_date date).include?(variable_type)
      date_filters(sheet_scope, hash)
    else # Create a Filter that shows if the variable is present.
      presence_filters(hash)
    end
  end

  def statistic_filters
    [
      { filters: [], name: 'N',      tooltip: 'N',      calculation: 'array_count'                            },
      { filters: [], name: 'Mean',   tooltip: 'Mean',   calculation: 'array_mean'                             },
      { filters: [], name: 'StdDev', tooltip: 'StdDev', calculation: 'array_standard_deviation', symbol: 'pm' },
      { filters: [], name: 'Median', tooltip: 'Median', calculation: 'array_median'                           },
      { filters: [], name: 'Min',    tooltip: 'Min',    calculation: 'array_min'                              },
      { filters: [], name: 'Max',    tooltip: 'Max',    calculation: 'array_max'                              }
    ]
  end

  def domain_filters(sheet_scope, include_missing)
    filters = [{ filters: [{ variable: self, value: nil, operator: 'any' }], name: 'N', tooltip: 'N', calculation: 'array_count' }]
    unique_responses = unique_responses_for_sheets(sheet_scope)
    filters += options_or_autocomplete(include_missing)
               .select { |h| unique_responses.include?(h[:value]) }
               .collect { |h| h.merge(filters: [{ variable: self, value: h[:value] }], tooltip: h[:value].present? ? "#{h[:value]}: #{h[:name]}" : h[:name]) }
    filters << blank_filter if include_missing
    filters
  end

  def design_filters
    project.designs.order(:name).collect do |design|
      {
        filters: [{ variable: self, value: design.id.to_s }],
        name: design.name,
        tooltip: design.name,
        link: "/projects/#{project.to_param}/reports/designs/#{design.id}/advanced",
        value: design.id.to_s,
        calculation: 'array_count',
        hide_value: '1'
      }
    end
  end

  def site_filters
    project.sites.order(:name).collect do |site|
      {
        filters: [{ variable: self, value: site.id.to_s }],
        name: site.name,
        tooltip: site.name,
        value: site.id.to_s,
        calculation: 'array_count',
        hide_value: '1'
      }
    end
  end

  def date_filters(sheet_scope, hash)
    date_buckets = generate_date_buckets(sheet_scope, hash[:by] || 'month')
    date_buckets.reverse! unless hash[:axis] == 'col'
    date_buckets.collect do |date_bucket|
      {
        filters: [{ variable: self,
                    start_date: date_bucket[:start_date],
                    end_date: date_bucket[:end_date] }],
        name: date_bucket[:name], tooltip: date_bucket[:tooltip],
        calculation: 'array_count',
        start_date: date_bucket[:start_date], end_date: date_bucket[:end_date]
      }
    end
  end

  def presence_filters(hash)
    display_name = "#{"#{hash[:variable].display_name} " if hash[:axis] == 'col'}Any"
    [{ filters: [{ variable: self, value: nil, operator: 'any' }], name: display_name, tooltip: display_name, muted: false }]
  end

  def missing_filter
    { filters: [{ variable: self, value: nil, operator: 'missing' }], name: 'Missing', tooltip: 'Missing', muted: true }
  end

  def blank_filter
    { filters: [{ variable: self, value: nil, operator: 'blank' }], name: 'Blank', tooltip: 'Blank', muted: true }
  end

  def unique_responses_for_sheets(sheet_scope)
    if variable_type == 'checkbox'
      sheet_scope.sheet_responses_for_checkboxes(self).uniq
    else
      sheet_scope.sheet_responses(self).uniq
    end
  end

  def edge_date(sheet_scope, method)
    if variable_type == 'sheet_date'
      sheet_scope.pluck(:created_at).send(method).to_date
    else
      Date.strptime(sheet_scope.sheet_responses(self).reject(&:blank?).send(method), '%Y-%m-%d')
    end
  rescue
    Time.zone.today
  end

  def min_date(sheet_scope)
    edge_date(sheet_scope, :min)
  end

  def max_date(sheet_scope)
    edge_date(sheet_scope, :max)
  end

  def generate_date_buckets(sheet_scope, by)
    max_length_of_time_in_years = 200
    min = min_date(sheet_scope)
    max = max_date(sheet_scope)
    date_buckets = []
    last_years = (min.year..max.year).last(max_length_of_time_in_years)
    case by
    when 'week'
      current_cweek = min.cweek
      last_years.each do |year|
        (current_cweek..Date.parse("#{year}-12-28").cweek).each do |cweek|
          start_date = Date.commercial(year, cweek) - 1.day
          end_date = Date.commercial(year, cweek) + 5.days
          date_buckets << { name: "Week #{cweek}", tooltip: "#{year} #{start_date.strftime('%m/%d')}-#{end_date.strftime('%m/%d')} Week #{cweek}", start_date: start_date, end_date: end_date }
          break if year == max.year && cweek == max.cweek
        end
        current_cweek = 1
      end
    when 'month'
      current_month = min.month
      last_years.each do |year|
        (current_month..12).each do |month|
          start_date = Date.parse("#{year}-#{month}-01")
          end_date = Date.parse("#{year}-#{month}-01").end_of_month
          date_buckets << { name: "#{Date::ABBR_MONTHNAMES[month]} #{year}", tooltip: "#{Date::MONTHNAMES[month]} #{year}", start_date: start_date, end_date: end_date }
          break if year == max.year && month == max.month
        end
        current_month = 1
      end
    when 'year'
      last_years.each do |year|
        start_date = Date.parse("#{year}-01-01")
        end_date = Date.parse("#{year}-12-31")
        date_buckets << { name: year.to_s, tooltip: year.to_s, start_date: start_date, end_date: end_date }
      end
    end
    date_buckets
  end

  def self.site(project_id)
    new project_id: project_id, name: 'site', display_name: 'Site', variable_type: 'site'
  end

  def self.sheet_date(project_id)
    new project_id: project_id, name: 'sheet_date', display_name: 'Sheet Date', variable_type: 'sheet_date'
  end

  def self.design(project_id)
    new project_id: project_id, name: 'design', display_name: 'Design', variable_type: 'design'
  end

  def sas_informat
    if %w(string file).include?(variable_type)
      '$500'
    elsif %w(date).include?(variable_type)
      'yymmdd10'
    elsif %w(dropdown radio).include?(variable_type) && domain && !domain.all_numeric?
      '$500'
    elsif %w(numeric integer calculated imperial_height imperial_weight dropdown radio time_of_day time_duration).include?(variable_type)
      'best32'
    else # elsif %w(text).include?(variable_type)
      '$5000'
    end
  end

  def sas_format
    case variable_type
    when 'time_of_day'
      'time8'
    else
      sas_informat
    end
  end

  def csv_column
    if variable_type == 'checkbox'
      domain_options.collect { |domain_option| option_variable_name(domain_option) }
    else
      name
    end
  end

  def csv_columns_and_names
    if variable_type == 'checkbox'
      domain_options.collect do |domain_option|
        [option_variable_name(domain_option), "#{display_name} - #{domain_option.value_and_name}"]
      end
    else
      [[name, display_name]]
    end
  end

  def sas_informat_definition
    if variable_type == 'checkbox'
      option_informat = (domain && !domain.all_numeric? ? '$500' : 'best32')
      domain_options.collect { |domain_option| "  informat #{option_variable_name(domain_option)} #{option_informat}. ;" }
    else
      "  informat #{name} #{sas_informat}. ;"
    end
  end

  def sas_format_definition
    if variable_type == 'checkbox'
      option_format = (domain && !domain.all_numeric? ? '$500' : 'best32')
      domain_options.collect { |domain_option| "  format #{option_variable_name(domain_option)} #{option_format}. ;" }
    else
      "  format #{name} #{sas_format}. ;"
    end
  end

  def sas_format_label
    if variable_type == 'checkbox'
      domain_options.collect { |domain_option| "  label #{option_variable_name(domain_option)}='#{display_name.gsub("'", "''")} (#{domain_option.name.gsub("'", "''")})' ;" }
    else
      "  label #{name}='#{display_name.gsub("'", "''")}';"
    end
  end

  def sas_format_domain
    if domain
      case variable_type
      when 'checkbox'
        domain_options.collect { |domain_option| "  format #{option_variable_name(domain_option)} #{domain.sas_domain_name}. ;" }
      else
        "  format #{name} #{domain.sas_domain_name}. ;"
      end
    else
      nil
    end
  end

  def option_variable_name(domain_option)
    "#{name}__#{domain_option.value.gsub(/[^a-zA-Z0-9_]/, '_')}".last(28).gsub(/^_+/, '')
  end

  def date_order
    case format
    when '%Y-%m-%d'
      %w(year month day)
    when '%d/%m/%Y'
      %w(day month year)
    else
      %w(month day year)
    end
  end

  def date_formatting(component)
    case component
    when 'month'
      ['mm', '%m']
    when 'day'
      ['dd', '%d']
    when 'year'
      ['yyyy', '%Y']
    end
  end

  def date_separator
    case format
    when '%Y-%m-%d'
      '-'
    else
      '/'
    end
  end

  def export_units
    case variable_type
    when 'imperial_height'
      'inches'
    when 'imperial_weight'
      'ounces'
    when 'time_of_day'
      'seconds since midnight'
    when 'time_duration'
      'seconds'
    else
      units
    end
  end

  def export_variable_type
    case variable_type
    when 'imperial_height', 'imperial_weight', 'time_of_day', 'time_duration'
      'integer'
    else
      variable_type
    end
  end

  # Validation Module

  def validator
    @validator ||= Validation.for(self)
  end

  def value_in_range?(value)
    if value.is_a?(ActionController::Parameters)
      value = value.to_unsafe_hash
    end
    validator.value_in_range?(value)
  end

  def response_to_value(response)
    if response.is_a?(ActionController::Parameters)
      response = response.to_unsafe_hash
    end
    validator.response_to_value(response)
  end

  def response_to_raw_value(response)
    if response.is_a?(ActionController::Parameters)
      response = response.to_unsafe_hash
    end
    validator.response_to_raw_value(response)
  end

  def validate_value(value, design_option)
    validation_hash = value_in_range?(value)
    validation_code(validation_hash[:status], design_option)
  end

  def validation_code(status, design_option)
    if %w(invalid out_of_range).include?(status)
      'error'
    elsif status == 'blank' && design_option.required?
      'error'
    elsif status == 'in_hard_range'
      'warning'
    elsif status == 'blank' && design_option.recommended?
      'warning'
    else
      'valid'
    end
  end

  def display_class(is_grid)
    if is_grid || %w(horizontal scale).include?(alignment)
      "#{variable_type}-inline"
    else
      variable_type
    end
  end

  def single_choice?
    variable_type != 'checkbox'
  end

  # For Time Duration Variables
  def no_hours?
    time_duration_format == 'mm:ss'
  end

  def time_of_day_format_name
    TIME_OF_DAY_FORMATS.find { |_name, value| value == time_of_day_format }.first
  end

  def time_duration_format_name
    TIME_DURATION_FORMATS.find { |_name, value| value == time_duration_format }.first
  end

  # For Time of Day Variables
  def twelve_hour_clock?
    %w(12hour 12hour-pm).include?(time_of_day_format)
  end

  def update_domain_values!
    return unless saved_changes.key?(:domain_id)
    (old_domain_id, new_domain_id) = saved_changes[:domain_id]
    old_domain = project.domains.find_by(id: old_domain_id)
    new_domain = project.domains.find_by(id: new_domain_id)
    old_domain.remove_domain_values! if old_domain
    new_domain.add_domain_values! if new_domain
  end

  def display_layout_name
    DISPLAY_LAYOUTS.find { |_name, value| value == display_layout }.first
  end
end
