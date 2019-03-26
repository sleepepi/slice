# frozen_string_literal: true

# Defines how data is captured, displayed, and exported.
class Variable < ApplicationRecord
  # Constants
  TYPE_ALL = %w(
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
  )

  TYPE = TYPE_ALL.sort.collect { |i| [i, i] }

  TYPE_SEARCHABLE = TYPE_ALL - %w(grid)

  TYPE_DOMAIN = %w(dropdown checkbox radio integer numeric)

  DISPLAY_LAYOUTS = [
    ["Question above answer ", "gone"],
    ["Question inline with answer", "visible"]
  ]

  ALIGNMENT = [
    ["Horizontal", "horizontal"],
    ["Vertical", "vertical"],
    ["Scale", "scale"]
  ]

  DATE_FORMATS = [
    ["mm/dd/yyyy (ex: 12/31/2017)", "mm/dd/yyyy"],
    ["yyyy-mm-dd (ex: 2017-12-31)", "yyyy-mm-dd"],
    ["dd/mm/yyyy (ex: 31/12/2017)", "dd/mm/yyyy"],
    ["dd-mmm-yyyy (ex: 31-DEC-2017)", "dd-mmm-yyyy"]
  ]

  TIME_OF_DAY_FORMATS = [
    ["24-Hour", "24hour"],
    ["12-Hour AM/PM [AM]", "12hour"],
    ["12-Hour AM/PM [PM]", "12hour-pm"]
  ]

  TIME_DURATION_FORMATS = [
    ["HH:MM:SS", "hh:mm:ss"],
    ["HH:MM", "hh:mm"],
    ["MM:SS", "mm:ss"]
  ]

  # Callbacks
  after_update :update_domain_values!

  attr_accessor :questions, :grid_tokens

  # Concerns
  include Calculable
  include DateAndTimeParser
  include Deletable
  include Searchable

  include Squishable
  squish :name, :display_name, :field_note, :prepend, :append, :units, :calculated_format

  include Translatable
  translates :display_name, :field_note, :prepend, :units, :append

  # Scopes
  scope :with_user, ->(arg) { where(user_id: arg) }

  # Validations
  validates :name, :display_name, :variable_type, :project_id, presence: true
  validates :name,
            format: { with: /\A[a-z]\w*\Z/i },
            length: { maximum: 32 },
            exclusion: { in: %w(new edit create update destroy overlap null) }
  validates :name, uniqueness: { scope: [:deleted, :project_id] }
  validates :time_of_day_format, inclusion: { in: TIME_OF_DAY_FORMATS.collect(&:second) }
  validates :time_duration_format, inclusion: { in: TIME_DURATION_FORMATS.collect(&:second) }

  # Relationships
  belongs_to :project
  belongs_to :user, optional: true # TODO: should not be optional
  belongs_to :domain, optional: true, counter_cache: true
  belongs_to :updater, optional: true, class_name: "User", foreign_key: "updater_id"
  has_many :sheet_variables
  has_many :grids
  has_many :responses
  has_many :design_options, -> { order :position }
  has_many :designs, through: :design_options
  has_many :child_grid_variables, -> { order(Arel.sql("position nulls last")) },
           class_name: "GridVariable", source: :child_variable,
           foreign_key: :parent_variable_id
  has_many :child_variables, through: :child_grid_variables
  has_many :parent_grid_variables, class_name: "GridVariable", source: :parent_variable, foreign_key: :child_variable_id
  has_many :parent_variables, through: :parent_grid_variables

  # Methods
  def self.searchable_attributes
    %w(name description display_name)
  end

  def destroy
    super
    Domain.reset_counters(domain_id, :variables) unless domain_id.nil?
  end

  def create_variables_from_questions!
    return unless variable_type == "grid" && questions.present?
    questions.select { |hash| hash[:question_name].present? }.each_with_index do |question_hash, index|
      question_hash = question_hash.symbolize_keys
      name = question_hash[:question_name].to_s.downcase
                                          .gsub(/[^a-zA-Z0-9]/, "_")
                                          .gsub(/^[\d_]/, "n")
                                          .gsub(/_{2,}/, "_")
                                          .gsub(/_$/, "")[0..31].strip
      name = "var_#{SecureRandom.hex(12)}" if project.variables.where(name: name).size != 0
      new_variable_type = if Design::QUESTION_TYPES.collect(&:second).include?(question_hash[:question_type])
                            question_hash[:question_type]
                          else
                            "string"
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
    unarchived_domain_options = domain_options.where("domain_options.archived = ? OR domain_options.value IN (?)", false, response)
    return unarchived_domain_options unless current_user
    site_ids = current_user.all_editable_sites.where(project_id: project_id).select(:id)
    unarchived_domain_options.where(site_id: site_ids).or(unarchived_domain_options.where(site_id: nil))
  end

  def autocomplete_array
    autocomplete_values.to_s.split(/[\n\r]/).collect(&:strip).reject(&:blank?)
  end

  def uses_scale?
    %w(radio checkbox).include?(variable_type) && alignment == "scale"
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
      if variable_type == "file"
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
    result = ""
    minimum = hard_minimum || soft_minimum
    maximum = hard_maximum || soft_maximum
    with_units = (units.blank? ? "" : " #{units}")
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
    child_grid_variables.destroy_all
    grid_tokens.each_with_index do |grid_hash, index|
      next unless grid_hash[:variable_id].to_i.positive?
      child_grid_variables.create(
        project_id: project_id,
        child_variable_id: grid_hash[:variable_id].to_i,
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

  # Responses that are user submitted and not on autocomplete list
  def user_submitted_sheet_variables
    sheet_variables.reject { |sv| autocomplete_array.include?(sv.value.to_s.strip) || sv.value.to_s.strip.blank? }
  end

  def formatted_calculation
    readable_calculation.to_s.gsub(/\?|\:/, "<br/>&nbsp;\0<br/>").html_safe
  end

  def sas_informat
    if %w(string file).include?(variable_type)
      "$500"
    elsif %w(date).include?(variable_type)
      "yymmdd10"
    elsif %w(dropdown radio).include?(variable_type) && domain && !domain.all_numeric?
      "$500"
    elsif %w(numeric integer calculated imperial_height imperial_weight dropdown radio time_of_day time_duration).include?(variable_type)
      "best32"
    else # elsif %w(text).include?(variable_type)
      "$5000"
    end
  end

  def sas_format
    case variable_type
    when "time_of_day"
      "time8"
    else
      sas_informat
    end
  end

  def csv_column
    if variable_type == "checkbox"
      domain_options.collect { |domain_option| option_variable_name(domain_option) }
    else
      name
    end
  end

  def csv_columns_and_names
    if variable_type == "checkbox"
      domain_options.collect do |domain_option|
        [option_variable_name(domain_option), "#{display_name} - #{domain_option.value_and_name}"]
      end
    else
      [[name, display_name]]
    end
  end

  def sas_informat_definition
    if variable_type == "checkbox"
      option_informat = (domain && !domain.all_numeric? ? "$500" : "best32")
      domain_options.collect { |domain_option| "  informat #{option_variable_name(domain_option)} #{option_informat}. ;" }
    else
      "  informat #{name} #{sas_informat}. ;"
    end
  end

  def sas_format_definition
    if variable_type == "checkbox"
      option_format = (domain && !domain.all_numeric? ? "$500" : "best32")
      domain_options.collect { |domain_option| "  format #{option_variable_name(domain_option)} #{option_format}. ;" }
    else
      "  format #{name} #{sas_format}. ;"
    end
  end

  def sas_format_label
    if variable_type == "checkbox"
      domain_options.collect { |domain_option| "  label #{option_variable_name(domain_option)}='#{display_name.gsub("'", "''")} (#{domain_option.name.gsub("'", "''")})' ;" }
    else
      "  label #{name}='#{display_name.gsub("'", "''")}';"
    end
  end

  def sas_format_domain
    if domain
      case variable_type
      when "checkbox"
        domain_options.collect { |domain_option| "  format #{option_variable_name(domain_option)} #{domain.sas_domain_name}. ;" }
      else
        "  format #{name} #{domain.sas_domain_name}. ;"
      end
    else
      nil
    end
  end

  def option_variable_name(domain_option)
    "#{name}__#{domain_option.value.gsub(/[^a-zA-Z0-9_]/, '_')}".last(28).gsub(/^_+/, "")
  end

  def export_units
    case variable_type
    when "imperial_height"
      "inches"
    when "imperial_weight"
      "ounces"
    when "time_of_day"
      "seconds since midnight"
    when "time_duration"
      "seconds"
    else
      units
    end
  end

  def export_variable_type
    case variable_type
    when "imperial_height", "imperial_weight", "time_of_day", "time_duration"
      "integer"
    else
      variable_type
    end
  end

  # Validation Module

  def validator
    @validator ||= Validation.for(self)
  end

  def value_in_range?(value)
    value = clean_value(value)
    validator.value_in_range?(value)
  end

  def response_to_value(response)
    response = clean_value(response)
    validator.response_to_value(response)
  end

  def response_to_raw_value(response)
    response = clean_value(response)
    validator.response_to_raw_value(response)
  end

  def validate_value(value, design_option)
    validation_hash = value_in_range?(value)
    validation_code(validation_hash[:status], design_option)
  end

  def validation_code(status, design_option)
    if %w(invalid out_of_range).include?(status)
      "error"
    elsif status == "blank" && design_option.required?
      "error"
    elsif status == "in_hard_range"
      "warning"
    elsif status == "blank" && design_option.recommended?
      "warning"
    else
      "valid"
    end
  end

  def display_inline?(is_grid)
    is_grid || %w(horizontal scale).include?(alignment)
  end

  def single_choice?
    variable_type != "checkbox"
  end

  # For Time Duration Variables
  def no_hours?
    time_duration_format == "mm:ss"
  end

  def time_of_day_format_name
    TIME_OF_DAY_FORMATS.find { |_name, value| value == time_of_day_format }.first
  end

  def time_duration_format_name
    TIME_DURATION_FORMATS.find { |_name, value| value == time_duration_format }.first
  end

  def date_format_name
    DATE_FORMATS.find { |_name, value| value == date_format }.first
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
    old_domain.remove_domain_values!(self) if old_domain
    new_domain.add_domain_values!(self) if new_domain
  end

  def save_translation!(variable_params)
    if World.translate_language?
      Variable.translatable_attributes.each do |attribute|
        next unless variable_params.key?(attribute)
        translation = variable_params.delete(attribute)
        save_object_translation!(self, attribute, translation)
      end
    end
    result = update(variable_params)
    update_grid_tokens! if result
    result
  end

  private

  def clean_value(value)
    value.is_a?(ActionController::Parameters) ? value.to_unsafe_hash : value
  end
end
