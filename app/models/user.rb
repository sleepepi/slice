# The user class provides methods to scope resources in system that the user is
# allowed to view and edit.
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  serialize :pagination, Hash
  serialize :email_notifications, Hash

  EMAILABLES = [
    [:daily_digest, 'Receive daily digest emails of sheets that have been created the previous day']
  ]

  # Concerns
  include Deletable

  # Model Validation
  validates :first_name, :last_name, presence: true

  # Model Relationships
  has_many :adverse_events, -> { where deleted: false }
  has_many :adverse_event_comments, -> { where deleted: false }
  has_many :adverse_event_files
  has_many :adverse_event_users
  has_many :categories, -> { where deleted: false }
  has_many :comments, -> { where deleted: false }
  has_many :designs, -> { where deleted: false }
  has_many :events, -> { where deleted: false }
  has_many :exports, -> { where deleted: false }
  has_many :projects, -> { where deleted: false }
  has_many :project_favorites
  has_many :randomization_schemes, -> { where deleted: false }
  has_many :reports, -> { where deleted: false }
  has_many :sheets, -> { where deleted: false }
  has_many :sites, -> { where deleted: false }
  has_many :subjects, -> { where deleted: false }
  has_many :variables, -> { where deleted: false }

  # Named Scopes
  scope :with_sheet, -> { where 'users.id in (select DISTINCT(sheets.user_id) from sheets where sheets.deleted = ?)', false }
  scope :with_design, -> { where 'users.id in (select DISTINCT(designs.user_id) from designs where designs.deleted = ?)', false }
  scope :with_variable_on_project, -> (arg) { where 'users.id in (select DISTINCT(variables.user_id) from variables where variables.project_id in (?) and variables.deleted = ?)', arg, false }
  scope :with_project, -> (*args) { where 'users.id in (select projects.user_id from projects where projects.id IN (?) and projects.deleted = ?) or users.id in (select project_users.user_id from project_users where project_users.project_id IN (?) and project_users.editor IN (?))', args.first, false, args.first, args[1] }

  def self.search(arg)
    term = arg.to_s.downcase.gsub(/^| |$/, '%')
    conditions = [
      'LOWER(first_name) LIKE ?',
      'LOWER(last_name) LIKE ?',
      'LOWER(email) LIKE ?',
      '((LOWER(first_name) || LOWER(last_name)) LIKE ?)',
      '((LOWER(last_name) || LOWER(first_name)) LIKE ?)'
    ]
    terms = [term] * conditions.count
    where conditions.join(' or '), *terms
  end

  # User Methods

  def avatar_url(size = 80, default = 'mm')
    gravatar_id = Digest::MD5.hexdigest(email.to_s.downcase)
    "//gravatar.com/avatar/#{gravatar_id}.png?&s=#{size}&r=pg&d=#{default}"
  end

  def associated_users
    User.current.with_project(all_projects.pluck(:id), [true, false])
  end

  def all_favorite_projects
    @all_favorite_projects ||= begin
      all_viewable_and_site_projects.by_favorite(id).where('project_favorites.favorite = ?', true).order(:name)
    end
  end

  def all_unarchived_projects
    @all_unarchived_projects ||= begin
      all_viewable_and_site_projects.by_favorite(id).unarchived
    end
  end

  def all_archived_projects
    @all_archived_projects ||= begin
      all_viewable_and_site_projects.by_favorite(id).archived.order(:name)
    end
  end

  def all_projects
    @all_projects ||= begin
      Project.current.with_editor(id, true)
    end
  end

  def all_viewable_projects
    Project.current.with_editor(id, [true, false])
  end

  def all_viewable_and_site_projects
    Project.current.viewable_by_user(self)
  end

  # Project Owners, Project Editors, and Site Editors
  def all_sheet_editable_projects
    Project.current.editable_by_user(self)
  end

  def all_reports
    Report.current.where(user_id: id)
  end

  def all_viewable_reports
    Report.current.where(user_id: id)
  end

  def all_designs
    Design.current.with_project(all_projects.select(:id)).blinding_scope(self)
  end

  def all_viewable_designs
    Design.current.with_project(all_viewable_and_site_projects.select(:id)).blinding_scope(self)
  end

  def all_variables
    Variable.current.with_project(all_projects.pluck(:id))
  end

  def all_viewable_variables
    Variable.current.with_project(all_viewable_and_site_projects.pluck(:id))
  end

  # Project Editors and Site Editors on that site can modify sheet
  def all_sheets
    Sheet.current.with_site(all_editable_sites.select(:id)).where(design_id: all_viewable_designs.select(:id))
  end

  # Project Editors and Viewers and Site Members can view sheets
  def all_viewable_sheets
    Sheet.current.with_site(all_viewable_sites.select(:id)).where(design_id: all_viewable_designs.select(:id))
  end

  # Only Project Editors or Project Owner can modify randomization
  def all_randomizations
    Randomization.current.where(project_id: all_projects.select(:id)).blinding_scope(self)
  end

  # Project Editors and Viewers and Site Members can view randomization
  def all_viewable_randomizations
    Randomization.current.with_site(all_viewable_sites.select(:id)).blinding_scope(self)
  end

  # Only Project Editors and Site Editors can modify adverse event
  def all_adverse_events
    AdverseEvent.current.with_site(all_editable_sites.select(:id)).blinding_scope(self)
  end

  # Project Editors and Viewers and Site Members can view adverse event
  def all_viewable_adverse_events
    AdverseEvent.current.with_site(all_viewable_sites.select(:id)).blinding_scope(self)
  end

  def all_viewable_adverse_event_comments
    AdverseEventComment.current.where(adverse_event_id: all_viewable_adverse_events.select(:id))
  end

  # Comment creator can edit, or project editors and owners
  def all_adverse_event_comments
    AdverseEventComment.current.where('user_id = ? or project_id in (?)', id, all_projects.select(:id))
  end

  # Project Editors
  def all_sites
    @all_sites ||= begin
      Site.current.where(project_id: all_projects.select(:id))
    end
  end

  # Project Editors and Viewers and Site Members
  def all_viewable_sites
    Site.current.with_project_or_as_site_user(all_viewable_projects.select(:id), id)
  end

  # Project Editors and Site Editors
  def all_editable_sites
    Site.current.with_project_or_as_site_editor(all_projects.select(:id), id)
  end

  # Project Editors and Site Editors can modify subjects
  def all_subjects
    Subject.current.where(site_id: all_editable_sites.select(:id))
  end

  # Project Editors and Viewers and Site Members can view subjects
  def all_viewable_subjects
    Subject.current.where(site_id: all_viewable_sites.select(:id))
  end

  def all_exports
    @all_exports ||= begin
      Export.current.where(user_id: id)
    end
  end

  def all_viewable_exports
    @all_viewable_exports ||= begin
      Export.current.where(user_id: id)
    end
  end

  def unviewed_active_exports
    @unviewed_active_exports ||= begin
      all_viewable_exports.where(status: 'ready', viewed: false)
    end
  end

  def unviewed_pending_exports
    @unviewed_pending_exports ||= begin
      all_viewable_exports.where(status: 'pending', viewed: false)
    end
  end

  def all_comments
    comments
  end

  def all_viewable_comments
    Comment.current.where(sheet_id: all_viewable_sheets.select(:id))
  end

  def all_deletable_comments
    @all_deletable_comments ||= begin
      Comment.current.where('sheet_id IN (?) or user_id = ?', all_sheets.select(:id), id)
    end
  end

  # Overriding Devise built-in active_for_authentication? method
  def active_for_authentication?
    super && !deleted?
  end

  def destroy
    super
    update_column :updated_at, Time.zone.now
  end

  def all_digest_projects
    @all_digest_projects ||= begin
      all_viewable_and_site_projects.where(disable_all_emails: false).select { |p| self.emails_enabled? && self.email_on?(:daily_digest) && self.email_on?("project_#{p.id}_daily_digest") }
    end
  end

  def unseen_notifications?
    unseen_adverse_events.present?
  end

  def unseen_adverse_events
    all_viewable_adverse_events
      .joins("LEFT JOIN adverse_event_users ON adverse_event_users.user_id = #{id} and adverse_event_users.adverse_event_id = adverse_events.id")
      .where('adverse_event_users.last_viewed_at < adverse_events.updated_at or adverse_event_users.last_viewed_at IS NULL')
      .distinct(:id)
  end

  # All sheets created in the last day, or over the weekend if it's Monday
  # Ex: On Monday, returns sheets created since Friday morning (Time.zone.now - 3.day)
  # Ex: On Tuesday, returns sheets created since Monday morning (Time.zone.now - 1.day)
  def digest_sheets_created
    all_viewable_sheets.with_subject_status('valid').where(project_id: all_digest_projects.collect(&:id)).where('sheets.created_at > ?', (Time.zone.now.monday? ? Time.zone.now - 3.day : Time.zone.now - 1.day))
  end

  def digest_comments
    all_viewable_comments.with_project(all_digest_projects.collect(&:id)).where('comments.created_at > ?', (Time.zone.now.monday? ? Time.zone.now - 3.day : Time.zone.now - 1.day)).order(:created_at)
  end

  def email_on?(value)
    [nil, true].include?(email_notifications[value.to_s])
  end

  def name
    "#{first_name} #{last_name}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end
end
