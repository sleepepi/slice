# frozen_string_literal: true

# Defines a collection of responses to a design for a subject.
class Sheet < ApplicationRecord
  # Constants
  ORDERS = {
    "site" => "sites.name",
    "site desc" => "sites.name desc",
    "design" => "designs.name",
    "design desc" => "designs.name desc",
    "created_by" => "users.full_name",
    "created_by desc" => "users.full_name desc nulls last",
    "subject" => "subjects.subject_code",
    "subject desc" => "subjects.subject_code desc",
    "percent" => "sheets.percent",
    "percent desc" => "sheets.percent desc nulls last",
    "created" => "sheets.created_at",
    "created desc" => "sheets.created_at desc",
    "edited" => "sheets.last_edited_at",
    "edited desc" => "sheets.last_edited_at desc nulls last"
  }
  DEFAULT_ORDER = "sheets.last_edited_at desc nulls last"

  # Concerns
  include AutoLockable
  include Coverageable
  include Deletable
  include Evaluatable
  include Forkable
  include Latexable
  include Siteable

  # Callbacks
  before_save :check_subject_event_subject_match

  # Scopes
  scope :search, ->(arg) { where("sheets.subject_id in (select subjects.id from subjects where subjects.deleted = ? and LOWER(subjects.subject_code) LIKE ?) or design_id in (select designs.id from designs where designs.deleted = ? and LOWER(designs.name) LIKE ?)", false, arg.to_s.downcase.gsub(/^| |$/, "%"), false, arg.to_s.downcase.gsub(/^| |$/, "%")).references(:designs) }
  scope :sheet_before, ->(*args) { where("sheets.created_at < ?", (args.first + 1.day).at_midnight) }
  scope :sheet_after, ->(*args) { where("sheets.created_at >= ?", args.first.at_midnight) }

  # Validations
  validates :authentication_token, uniqueness: true, allow_nil: true

  # Relationships
  belongs_to :design
  belongs_to :project
  belongs_to :subject
  belongs_to :user, optional: true
  belongs_to :last_user, optional: true, class_name: "User"
  belongs_to :subject_event, optional: true
  belongs_to :adverse_event, -> { current }, optional: true, touch: true
  belongs_to :ae_adverse_event, -> { current }, optional: true
  has_many :sheet_prints
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

  # Methods
  delegate :description, to: :design

  def name
    design ? design.name : "No Design"
  end

  def event_at
    created_at
  end

  def editable_by?(current_user)
    current_user.all_sheets.where(id: id).count == 1
  end

  def recently_created?
    last_edited_at.nil? || ((last_edited_at - created_at) / 1.minute).to_i.zero?
  end

  # This returns the maximum size of any grid.
  # Ex: A Sheet has two grid variables on it, one with 3 rows, and the other with 1.
  #     This function would return 2 (position is zero-indexed, so [0,1,2]). This
  #     number is used to combine grids on similar rows in the sheet grids export
  def max_grids_position
    Grid.where(sheet_variable_id: sheet_variables.select(:id)).pluck(:position).max || -1
  end

  def self.filter_variable(variable, current_user, operator, value: nil)
    token = Token.new(key: variable.name, operator: operator, variable: variable, value: value)
    Search.run_sheets(
      variable.project,
      current_user,
      current_user.all_viewable_sheets.where(project_id: variable.project.id).where(missing: false),
      token
    ).where(design_id: variable.designs.select(:id))
  end

  # Buffers with blank responses for sheets that don't have a sheet_variable for the specific variable
  def self.sheet_responses(variable)
    value_scope = SheetVariable.where(sheet_id: select(:id), variable_id: variable.id)
    responses = if variable.variable_type == "file"
                  value_scope.pluck(:response_file)
                else
                  value_scope.pluck_domain_option_value_or_value
                end
    responses + [""] * [all.count - responses.size, 0].max
  end

  def self.sheet_responses_for_checkboxes(variable)
    Response.where(sheet_id: select(:id), variable_id: variable.id).pluck_domain_option_value_or_value
  end

  def expanded_branching_logic(branching_logic)
    branching_logic.to_s.gsub(/\#{(\d+)}/) { variable_javascript_value($1) }
  end

  # TODO: Check speed of function using where vs find (caching and memory)
  def variable_javascript_value(variable_id)
    variable = design.variables.find { |v| v.id.to_s == variable_id.to_s }
    if variable
      sheet_variable = sheet_variables.find { |sv| sv.variable_id == variable.id }
      result = if sheet_variable
                 sheet_variable.get_response(:raw)
               else
                 variable.variable_type == "checkbox" ? [""] : ""
               end
      result.to_json
    else
      "\#{#{variable_id}}"
    end
  end

  def expanded_calculation(calculation)
    calculation.to_s.gsub(/\#{(\d+)}/) { variable_javascript_value_formatted($1) }
  end

  # Used for computing calculated variable calculation results.
  def variable_javascript_value_formatted(variable_id)
    variable = design.variables.find { |v| v.id.to_s == variable_id.to_s }
    if variable
      sheet_variable = sheet_variables.find { |sv| sv.variable_id == variable.id }
      result = sheet_variable&.get_response(:raw)
      if variable.variable_type == "checkbox"
        result || []
      else
        result.presence || "null"
      end
    else
      "\#{#{variable_id}}"
    end
  end

  def show_design_option?(branching_logic)
    return true if branching_logic.to_s.strip.blank?
    result = exec_js_context.eval(expanded_branching_logic(branching_logic))
    result == false ? false : true
  rescue ExecJS::Error => e
    Rails.logger.debug e
    Rails.logger.debug "SHEET: #{id}"
    Rails.logger.debug "SHEET: show_design_option?(#{branching_logic.inspect})"
    true
  end

  def grids
    Grid.where(
      sheet_variable_id: sheet_variables.joins(:variable).where(variables: { variable_type: "grid" }).select(:id)
    )
  end

  # Returns the file path with the relative location
  # - The name of the file as it will appear in the archive
  # - The original file, including the path to find it
  def files
    sheet_variables.with_files.select { |o| o.response_file.size > 0 }.collect do |sheet_variable|
      [
        "FILES/sheet_#{id}/#{sheet_variable.variable.name}/#{sheet_variable.response_file.to_s.split("/").last}",
        sheet_variable.response_file.path
      ]
    end
  end

  def self.array_responses(sheet_scope, variable)
    responses = []
    if variable && %w(site sheet_date).include?(variable.variable_type)
      responses = sheet_scope.includes(:subject).collect { |s| s.subject.site_id } if variable.variable_type == "site"
      responses = sheet_scope.pluck(:created_at) if variable.variable_type == "sheet_date"
    else
      responses = (variable ? SheetVariable.where(sheet_id: sheet_scope.select(:id), variable_id: variable.id).pluck_domain_option_value_or_value : [])
    end
    # Convert to integer or float
    variable && variable.variable_type == "integer" ? responses.map(&:to_i) : responses.map(&:to_f)
  end

  # Computes calculation for a scope of sheet responses
  # Ex: Sheet.array_calculation(Sheet.all, Variable.where(name: "age"), "array_mean")
  #     Would return the average of all ages on all sheets that contained age (as a sheet_variable, not as a grid or grid_response)
  def self.array_calculation(sheet_scope, variable, calculation)
    calculation = "array_count" if calculation.blank?
    number = \
      if calculation == "array_count"
        # New, to account for sheets that are scoped based on a
        # missing/non-entered value, should be counted as the count of sheets,
        # not the count of responses.
        Statistics.send(calculation, sheet_scope.pluck(:id))
      else
        Statistics.send(calculation, array_responses(sheet_scope, variable))
      end

    if calculation != "array_count" && !number.nil?
      number = \
        if variable.variable_type == "calculated" && variable.calculated_format.present?
          format(variable.calculated_format, number) rescue number
        else
          format("%0.02f", number)
        end
    end
    number
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

  def create_notifications!
    return unless design.notifications_enabled?
    users.each do |u|
      next if u == user
      notification = u.notifications.where(project_id: project_id, sheet_id: id).first_or_create
      notification.mark_as_unread!
    end
  end

  def original_attributes
    ignore_attributes = %w(created_at updated_at authentication_token deleted successfully_validated initial_language_code)
    previous_changes.reject { |k, _v| ignore_attributes.include?(k.to_s) }.collect { |k, v| [k, v[0]] }
  end

  def destroy
    super
    subject.update_uploaded_file_counts!
    subject_event&.update_coverage!
  end

  def update_associated_subject_events!
    subject_event&.reset_coverage!
    subject.subject_events
           .where(event_id: EventDesign.where(conditional_design_id: design_id).select(:event_id))
           .find_each(&:reset_coverage!)
  end

  def update_uploaded_file_counts!
    update_columns(
      uploaded_files_count: sheet_variables.with_files.size
    )
  end

  def find_next_design_option
    sheet_variable_array = sheet_variables.includes(:domain_option, responses: :domain_option, variable: { domain: :domain_options }).to_a
    current_design_option = nil
    current_section = nil
    page = 0
    design.design_options.includes(:section, :variable).each do |design_option|
      current_design_option = design_option
      next unless show_design_option?(design_option.branching_logic)
      page += 1
      if design_option.section
        current_section = current_design_option
      elsif design_option.variable
        sheet_variable = sheet_variable_array.select { |sv| sv.variable_id == design_option.variable.id }.first
        response = (sheet_variable ? sheet_variable.get_response(:raw) : nil)
        value = design_option.variable.response_to_value(response)
        validation_hash = design_option.variable.value_in_range?(value)
        break if validation_hash[:status].in?(%w(blank invalid out_of_range))
        current_section = nil
      end
    end
    if current_section
      [current_section, page - 1]
    else
      [current_design_option, page]
    end
  end

  def goto_page_number(page)
    current_page = 0
    design.design_options.includes(:section, :variable).each do |design_option|
      next unless show_design_option?(design_option.branching_logic)
      current_page += 1
      return design_option if current_page == page
    end
    nil
  end

  def audit_set_lasted_edited!
    transaction = sheet_transactions.first
    return unless transaction
    update(last_edited_at: transaction.created_at, last_user: transaction.user)
  end

  protected

  def check_subject_event_subject_match
    self.subject_event_id = nil if subject_event && subject_event.subject != subject
  end
end
