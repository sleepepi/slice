# frozen_string_literal: true

# Allows users to collaborate together to enter data across a series of
# subjects, events, and sites. Provides a method to share access with other
# users at varying degrees of control.
class Project < ApplicationRecord
  PER_PAGE = 40
  AUTO_LOCK_SHEETS = [
    ["Never lock sheets", "never"],
    ["After 24 hours", "after24hours"],
    ["After 1 week", "after1week"],
    ["After 1 month", "after1month"]
  ]

  mount_uploader :logo, ImageUploader

  # Concerns
  include Deletable
  include Searchable
  include ShortNameable
  include Sluggable
  include Squishable
  include AeReviews

  squish :name

  after_save :create_default_site, :create_default_categories

  # Scopes
  scope :with_editor, ->(*args) { where("projects.user_id = ? or projects.id in (select project_users.project_id from project_users where project_users.user_id = ? and project_users.editor IN (?))", args.first, args.first, args[1] ).references(:project_users) }
  scope :by_preferences, ->(arg) { joins("LEFT JOIN project_preferences ON project_preferences.project_id = projects.id and project_preferences.user_id = #{arg.to_i}").references(:project_preferences) }
  scope :archived, -> { where(project_preferences: { archived: true }) }
  scope :unarchived, -> { where(project_preferences: { archived: [nil, false] }) }
  scope :viewable_by_user, ->(arg) { where("projects.id IN (SELECT projects.id FROM projects WHERE projects.user_id = ?)
    OR projects.id IN (SELECT project_users.project_id FROM project_users WHERE project_users.user_id = ?)
    OR projects.id IN (SELECT sites.project_id FROM site_users, sites WHERE site_users.site_id = sites.id AND site_users.user_id = ?)", arg, arg, arg) }

  scope :editable_by_user, ->(arg) { where("projects.id IN (SELECT projects.id FROM projects WHERE projects.user_id = ?)
    OR projects.id IN (SELECT project_users.project_id FROM project_users WHERE project_users.user_id = ? and project_users.editor = ?)
    OR projects.id IN (SELECT sites.project_id FROM site_users, sites WHERE site_users.site_id = sites.id AND site_users.user_id = ? and site_users.editor = ?)", arg, arg, true, arg, true) }

  # Validations
  validates :name, :user_id, presence: true
  validates :slug, uniqueness: { scope: :deleted }, allow_blank: true
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ }, allow_blank: true
  validates :authentication_token, uniqueness: true, allow_nil: true

  # Relationships
  belongs_to :user

  has_many :project_users
  has_many :users, -> { current.order(:full_name) }, through: :project_users
  has_many :editors, -> { current.where(project_users: { editor: true }) }, through: :project_users, source: :user
  has_many :viewers, -> { current.where(project_users: { editor: false }) }, through: :project_users, source: :user
  has_many :site_users
  has_many :project_preferences
  has_many :adverse_events, -> { current.joins(:subject).merge(Subject.current) }
  has_many :categories, -> { current.order(:position) }
  has_many :checks, -> { current }
  has_many :check_filters, -> { current.joins(:check).merge(Check.current) }
  has_many :designs, -> { current }
  has_many :variables, -> { current }
  has_many :sections
  has_many :sheets, -> { current.joins(:subject).merge(Subject.current) }
  has_many :sites, -> { current.order(:name) }
  has_many :subjects, -> { current }
  has_many :exports, -> { current }
  has_many :events, -> { current }
  has_many :handoffs
  has_many :domains, -> { current }
  has_many :randomizations, -> { current }
  has_many :randomization_schemes, -> { current }
  has_many :tasks, -> { current }
  has_many :treatment_arms, -> { current.joins(:randomization_scheme).merge(RandomizationScheme.current) }
  has_many :grid_variables
  has_many :invites

  # Methods

  def destroy
    super
    update slug: nil
  end

  def name_with_date_for_file
    "#{name_for_file}_#{Time.zone.today.strftime('%Y%m%d')}"
  end

  def name_for_file
    name.gsub(/[^a-zA-Z0-9_]/, "_")
  end

  def owner?(current_user)
    user == current_user
  end

  # Project Owners and Project Editors
  def editable_by?(current_user)
    current_user.all_projects.where(id: id).count == 1
  end

  def site_or_project_editor?(current_user)
    current_user.all_sheet_editable_projects.where(id: id).count == 1
  end

  def subject_code_name_full
    subject_code_name.to_s.strip.blank? ? "Subject Code" : subject_code_name.to_s.strip
  end

  def create_valid_subject(site_id)
    create_default_site if sites.count.zero?
    site = sites.find_by(id: site_id)
    site_id = sites.first.id unless site
    subject_code = SecureRandom.hex(8)
    subjects.create(subject_code: subject_code, site_id: site_id)
  end

  def archived_by?(current_user)
    project_preference = preference_for_user(current_user)
    project_preference.present? && project_preference.archived?
  end

  def emails_enabled?(current_user)
    project_preference = preference_for_user(current_user)
    project_preference.nil? || (project_preference.present? && project_preference.emails_enabled?)
  end

  def preference_for_user(current_user)
    project_preferences.where(user_id: current_user.id).first_or_create
  end

  def unblinded?(current_user)
    !blinding_enabled? ||
      user_id == current_user.id ||
      project_users.where(user_id: current_user.id, unblinded: true).count.positive? ||
      site_users.where(user_id: current_user.id, unblinded: true).count.positive? ||
      ae_admin?(current_user) ||
      ae_team?(current_user)
  end

  def show_type
    hide_values_on_pdfs? ? :display_name : :name
  end

  # Returns project editors and project owner
  def unblinded_project_editors
    return project_editors unless blinding_enabled
    User.current
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = #{id} and project_users.user_id = users.id")
      .where("(project_users.editor = ? and project_users.unblinded = ?) or users.id = ?", true, true, user_id)
  end

  def project_editors
    User.current
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = #{id} and project_users.user_id = users.id")
      .where("project_users.editor = ? or users.id = ?", true, user_id)
  end

  def unblinded_members
    return members unless blinding_enabled
    User.current
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = #{id} and project_users.user_id = users.id")
      .joins("LEFT OUTER JOIN site_users ON site_users.project_id = #{id} and site_users.user_id = users.id")
      .where("users.id = ? or project_users.unblinded = ? or site_users.unblinded = ?", user_id, true, true)
  end

  def members
    User.current
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = #{id} and project_users.user_id = users.id")
      .joins("LEFT OUTER JOIN site_users ON site_users.project_id = #{id} and site_users.user_id = users.id")
      .where("users.id = ? or project_users.unblinded IS NOT NULL or site_users.unblinded IS NOT NULL", user_id)
  end

  # Included unblinded project members and unblinded members for specified site
  def unblinded_members_for_site(site)
    return members_for_site(site) unless blinding_enabled
    User.current
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = #{id} and project_users.user_id = users.id")
      .joins("LEFT OUTER JOIN site_users ON site_users.project_id = #{id} and site_users.user_id = users.id and site_users.site_id = #{site.id}")
      .where("users.id = ? or project_users.unblinded = ? or site_users.unblinded = ?", user_id, true, true)
  end

  # Includes project members and site members for specified site
  def members_for_site(site)
    User.current
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = #{id} and project_users.user_id = users.id")
      .joins("LEFT OUTER JOIN site_users ON site_users.project_id = #{id} and site_users.user_id = users.id and site_users.site_id = #{site.id}")
      .where("users.id = ? or project_users.unblinded IS NOT NULL or site_users.unblinded IS NOT NULL", user_id)
  end

  def transfer_to_user(new_owner, current_user)
    update user_id: new_owner.id
    project_user = project_users.where(user: current_user).first_or_create
    project_user.update editor: true
  end

  def auto_locking_enabled?
    ["", "never"].exclude?(auto_lock_sheets)
  end

  def auto_lock_name
    AUTO_LOCK_SHEETS.find { |_name, value| value == auto_lock_sheets }.first
  end

  # Project variables that are not part of a grid or on a design.
  def unassigned_variables
    variables.where.not(id:
      variables.where(id: design_options.select(:variable_id)).or(
        variables.where(id: grid_variables.select(:child_variable_id))
      )
    )
  end

  def design_options
    DesignOption.where(design: designs)
  end

  def id_and_token
    "#{id}-#{authentication_token}"
  end

  def set_token
    return if authentication_token.present?
    update authentication_token: SecureRandom.hex(12)
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    retry
  end

  # A ActiveRecord assocation of all users with a role on the project. Does not
  # include the role of the member.
  def team_users
    User.current.where(id: user_id)
    .or(
      User.current.where(id: project_users.select(:user_id))
    )
    .or(
      User.current.where(id: site_users.select(:user_id))
    )
    .or(
      User.current.where(id: ae_review_admins.select(:user_id))
    )
    .or(
      User.current.where(id: ae_team_members.select(:user_id))
    )
  end

  private

  # Creates a default site if the project has no site associated with it
  def create_default_site
    return unless sites.count.zero?
    sites.create(name: "Default Site", short_name: "Default Site", number: 1, user_id: user_id)
  end

  def create_default_categories
    return if categories.count.positive?
    categories.create(
      name: "Adverse Events",
      slug: "adverse-events",
      user_id: user_id,
      position: 1,
      use_for_adverse_events: true
    )
  end
end
