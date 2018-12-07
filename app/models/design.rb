# frozen_string_literal: true

# Provides a framework to layout a series of sections and variables that make
# up a data collection form.
class Design < ApplicationRecord
  # Uploaders
  mount_uploader :csv_file, SpreadsheetUploader

  # Constants
  ORDERS = {
    "category" => "categories.name, designs.name",
    "category desc" => "categories.name desc, designs.name",
    "variables" => "designs.variables_count",
    "variables desc" => "designs.variables_count desc",
    "design" => "designs.name",
    "design desc" => "designs.name desc"
  }
  DEFAULT_ORDER = "designs.name"

  QUESTION_TYPES = [
    ["free text", "string"],
    ["select one answer", "radio"],
    ["select multiple answers", "checkbox"],
    ["date", "date"],
    ["time of day", "time_of_day"],
    ["number", "numeric"],
    ["file upload", "file"]
  ]

  # Callbacks
  after_save :reset_sheet_total_response_count, :set_survey_slug

  # Concerns
  include Blindable
  include DateAndTimeParser
  include Deletable
  include Forkable
  include Searchable
  include ShortNameable
  include Sluggable

  include Squishable
  squish :name, :slug, :survey_slug, :short_name

  include Translatable
  translates :name

  attr_writer :questions
  attr_accessor :reimport

  # Validations
  validates :name, :user_id, :project_id, presence: true
  validates :name, uniqueness: { scope: [:deleted, :project_id] }
  validates :survey_slug, uniqueness: true, allow_nil: true
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ },
                   exclusion: { in: %w(new edit create update destroy) },
                   uniqueness: { scope: :project_id },
                   allow_nil: true

  validates :csv_file, presence: true, if: :reimport?

  # Relationships
  belongs_to :user
  belongs_to :project
  belongs_to :category, -> { current }, optional: true
  belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
  has_many :design_prints
  has_many :sheets, -> { current.joins(:subject).merge(Subject.current) }
  has_many :sections
  has_many :event_designs
  has_many :events, through: :event_designs
  has_many :design_options, -> { order :position }
  has_many :variables, through: :design_options
  has_many :ae_designments

  # Methods

  def self.searchable_attributes
    %w(name slug short_name)
  end

  def self.order_by_user_name
    joins("LEFT JOIN users ON users.id = designs.user_id")
      .order("users.full_name")
      .select("designs.*, users.full_name")
  end

  def self.order_by_user_name_desc
    joins("LEFT JOIN users ON users.id = designs.user_id")
      .order("users.full_name desc")
      .select("designs.*, users.full_name")
  end

  def questions
    @questions || [{ question_name: "", question_type: "free text" }]
  end

  def create_variables_from_questions!
    questions.reject { |hash| hash[:question_name].blank? }.each_with_index do |question_hash, position|
      name = question_hash[:question_name].to_s.downcase.gsub(/[^a-zA-Z0-9]/, "_").gsub(/^[\d_]/, "n").gsub(/_{2,}/, "_").gsub(/_$/, "")[0..31].strip
      name = "var_#{Digest::SHA1.hexdigest(Time.zone.now.usec.to_s)[0..27]}" if project.variables.where(name: name).size != 0
      variable_type = (QUESTION_TYPES.collect { |_name, value| value }.include?(question_hash[:question_type]) ? question_hash[:question_type] : "string")
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
      next unless variable && variable.variable_type == "grid"
      variable.child_variables.each do |child_variable|
        new_options << DesignOption.new(variable_id: child_variable.id)
      end
    end
    new_options
  end

  def branching_logic(design_option)
    design_option.branching_logic.to_s.gsub(/\#{(\d+)}/) { variable_replacement($1) }.to_json
  end

  def variable_replacement(variable_id)
    variable = variables.find_by(id: variable_id)
    if variable && ["radio"].include?(variable.variable_type)
      "$(\"[name='variables[#{variable.id}]']:checked\").val()"
    elsif variable && ["checkbox"].include?(variable.variable_type)
      "$.map($(\"[name='variables[#{variable.id}][]']:checked\"),function(el){return $(el).val();})"
    elsif variable
      "$(\"#variables_#{variable.id}\").val()"
    else
      "\#{#{variable_id}}"
    end
  end

  def main_sections
    design_options.joins(:section).where(sections: { level: 0 })
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

  def load_variables
    @load_variables ||= begin
      raw_variables = header_row
      raw_variables.reject! { |i| %w(Subject Site).include?(i) }
      variables = []
      raw_variables.each do |variable_token|
        (variable_name, variable_type) = variable_token.to_s.split(":")
        variable_type = "string" unless Variable::TYPE_IMPORTABLE.flatten.include?(variable_type)
        variables << { name: variable_name.gsub(/[^a-zA-Z_0-9]/, ""), display_name: variable_name.humanize, variable_type: variable_type, column_name: variable_token } unless variable_name.blank?
      end
      variables
    end
  end

  def header_row
    @header_row ||= begin
      result = []
      if csv_file.path
        current_line = 0
        CSV.parse(File.open(csv_file.path, "r:iso-8859-1:utf-8", &:read)) do |line|
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
      v = project.variables.find_by(name: name.to_s)
      next if hash[:ignore] == "1" or (not v and not Variable::TYPE_IMPORTABLE.flatten.include?(hash[:variable_type]))
      v = project.variables.create(name: name, display_name: hash[:display_name], variable_type: hash[:variable_type], updater_id: user_id, user_id: user_id) unless v
      new_variables << v
    end

    build_design_options_from_variable_array(new_variables.compact.uniq)

    set_total_rows
  end

  def build_design_options_from_variable_array(variables)
    variables.each_with_index do |variable, position|
      design_options.create variable_id: variable.id, position: position
    end
  end

  def set_total_rows
    counter = 0
    CSV.parse(File.open(csv_file.path, "r:iso-8859-1:utf-8", &:read), headers: true) { counter += 1 } if csv_file.path
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
      variable = project.variables.find_by(name: hash[:name])
      column_name = hash[:column_name]
      [variable, column_name]
    end

    CSV.parse(File.open(csv_file.path, "r:iso-8859-1:utf-8", &:read), headers: true) do |line|
      row = line.to_hash.with_indifferent_access
      subject = Subject.first_or_create_with_defaults(project, row["Subject"], row["Site"].to_s, current_user, default_site)
      if subject
        sheet = sheets.where(subject_id: subject.id).first_or_initialize(project_id: project_id, user_id: current_user.id)
        sheet.last_user_id = current_user.id
        sheet.last_edited_at = Time.zone.now
        transaction_type = (sheet.new_record? ? "sheet_create" : "sheet_update")
        variables_params = {}

        variables_and_column_names.each do |variable, column_name|
          if variable && Variable::TYPE_IMPORTABLE.flatten.include?(variable.variable_type)
            variables_params[variable.id.to_s] = variable.response_to_value(row[column_name].to_s)
          end
        end

        SheetTransaction.save_sheet!(sheet, {}, variables_params, current_user, remote_ip, transaction_type)
      end
      counter += 1
      update(rows_imported: counter) if (counter % 25).zero? || counter == total_rows
    end

    update import_ended_at: Time.zone.now
    notify_user! current_user
  end

  def notify_user!(current_user)
    UserMailer.import_complete(self, current_user).deliver_now if EMAILS_ENABLED
  end

  def insert_new_design_option!(design_option)
    design_options
      .where.not(id: design_option.id)
      .where("position >= ?", design_option.position)
      .find_each do |dopt|
        dopt.update(position: dopt.position + 1)
      end
    recalculate_design_option_positions!
  end

  def recalculate_design_option_positions!
    design_options.each_with_index { |design_option, index| design_option.update(position: index) }
    reset_sheet_total_response_count
    recompute_variables_count!
    reload
  end

  def recompute_variables_count!
    update variables_count: variables.count
  end

  def name_from_csv!
    return unless name.blank? && csv_file.path && csv_file.path.split("/").last
    self.name = csv_file.path.split("/").last.gsub(/csv|\./, "").humanize.capitalize
  end

  def generate_import_in_background(site_id, current_user, remote_ip)
    update rows_imported: 0, total_rows: 1, import_started_at: Time.zone.now, import_ended_at: nil
    fork_process(:generate_import, site_id, current_user, remote_ip)
  end

  def generate_import(site_id, current_user, remote_ip)
    site = project.sites.find_by(id: site_id)
    create_sheets!(site, current_user, remote_ip)
  end

  def reimport?
    reimport == "1"
  end

  def export_value(raw_data)
    raw_data ? id : name
  end

  def save_translation!(design_params)
    if World.translate_language?
      Design.translatable_attributes.each do |attribute|
        next unless design_params.key?(attribute)
        translation = design_params.delete(attribute)
        save_object_translation!(self, attribute, translation)
      end
    end
    update(design_params)
  end

  def destroy
    update slug: nil, survey_slug: nil
    super
  end

  private

  # Reset all associated sheets total_response_count to nil to trigger refresh of sheet answer coverage
  def reset_sheet_total_response_count
    sheets.where(missing: false).update_all(response_count: nil, total_response_count: nil, percent: nil)
    sheets.where(missing: true).update_all(response_count: 0, total_response_count: 0, percent: 100)
    SubjectEvent.where(id: sheets.select(:subject_event_id)).update_all(
      unblinded_responses_count: nil,
      unblinded_questions_count: nil,
      unblinded_percent: nil,
      blinded_responses_count: nil,
      blinded_questions_count: nil,
      blinded_percent: nil
    )
  end

  def set_survey_slug
    return unless survey_slug.blank? && publicly_available?
    self.survey_slug = name.parameterize
    self.survey_slug += "-#{SecureRandom.hex(8)}" unless valid?
    save
  end
end
