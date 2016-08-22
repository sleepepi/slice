# frozen_string_literal: true

# The user class provides methods to scope resources in system that the user is
# allowed to view and edit.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  serialize :email_notifications, Hash

  EMAILABLES = [
    [:daily_digest, 'Receive daily digest emails of sheets that have been created the previous day']
  ]

  # Concerns
  include Deletable, Expirable

  # Model Validation
  validates :first_name, :last_name, presence: true

  # Model Relationships
  has_many :adverse_events, -> { current }
  has_many :adverse_event_comments, -> { current }
  has_many :adverse_event_files
  has_many :adverse_event_users
  has_many :categories, -> { current }
  has_many :checks, -> { current }
  has_many :check_filters
  has_many :comments, -> { current }
  has_many :designs, -> { current }
  has_many :domains, -> { current }
  has_many :events, -> { current }
  has_many :exports, -> { current }
  has_many :handoffs
  has_many :notifications, -> { joins(:project).merge(Project.current) }
  has_many :projects, -> { current }
  has_many :project_favorites
  has_many :randomization_schemes, -> { current }
  has_many :sections
  has_many :sheet_unlock_requests, -> { current.joins(:sheet).merge(Sheet.current) }
  has_many :sheets, -> { current.joins(:subject).merge(Subject.current) }
  has_many :sites, -> { current }
  has_many :subjects, -> { current }
  has_many :tasks, -> { current }
  has_many :variables, -> { current }

  # Scopes
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

  def all_events
    Event.current.where(project_id: all_projects.select(:id)).blinding_scope(self)
  end

  def all_viewable_events
    Event.current.where(project_id: all_viewable_and_site_projects.select(:id)).blinding_scope(self)
  end

  def all_variables
    Variable.current.with_project(all_projects.pluck(:id))
  end

  def all_viewable_variables
    Variable.current.with_project(all_viewable_and_site_projects.pluck(:id))
  end

  # Project Editors and Site Editors on that site can modify sheet
  def all_sheets
    Sheet.current
         .with_site(all_editable_sites.select(:id))
         .where(design_id: all_viewable_designs.select(:id))
         .joins('LEFT OUTER JOIN subject_events ON subject_events.id = sheets.subject_event_id').distinct
         .where('sheets.subject_event_id IS NULL or subject_events.event_id IS NULL or subject_events.event_id IN (?)', all_viewable_events.select(:id))
  end

  # Project Editors and Viewers and Site Members can view sheets
  def all_viewable_sheets
    Sheet.current
         .with_site(all_viewable_sites.select(:id))
         .where(design_id: all_viewable_designs.select(:id))
         .joins('LEFT OUTER JOIN subject_events ON subject_events.id = sheets.subject_event_id').distinct
         .where('sheets.subject_event_id IS NULL or subject_events.event_id IS NULL or subject_events.event_id IN (?)', all_viewable_events.select(:id))
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

  def all_tasks
    Task.current.where(project_id: all_projects.select(:id)).blinding_scope(self)
  end

  def all_viewable_tasks
    Task.current.where(project_id: all_viewable_and_site_projects.select(:id)).blinding_scope(self)
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
    Site.current.where(project_id: all_projects.select(:id))
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
    exports
  end

  def all_viewable_exports
    exports
  end

  def all_viewable_comments
    Comment.current.where(sheet_id: all_viewable_sheets.select(:id))
  end

  def all_editable_comments
    Comment.current.where('sheet_id IN (?) or user_id = ?', all_sheets.select(:id), id)
  end

  def all_deletable_comments
    all_editable_comments
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
      all_viewable_and_site_projects.where(disable_all_emails: false).select do |p|
        emails_enabled? && email_on?(:daily_digest) && email_on?("project_#{p.id}_daily_digest")
      end
    end
  end

  def unread_notifications?
    notifications.where(read: false).present?
  end

  # All sheets created in the last day, or over the weekend if it's Monday
  # Ex: On Monday, returns sheets created since Friday morning (Time.zone.now - 3.day)
  # Ex: On Tuesday, returns sheets created since Monday morning (Time.zone.now - 1.day)
  def digest_sheets_created
    project_ids = all_digest_projects.collect(&:id)
    all_viewable_sheets.where(project_id: project_ids)
                       .where('sheets.created_at > ?', last_business_day)
  end

  def digest_comments
    project_ids = all_digest_projects.collect(&:id)
    all_viewable_comments.with_project(project_ids)
                         .where('comments.created_at > ?', last_business_day)
                         .order(:created_at)
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

  def nickname
    "#{first_name} #{last_name.first}"
  end

  def last_business_day
    if Time.zone.now.monday?
      Time.zone.now - 3.days
    else
      Time.zone.now - 1.day
    end
  end
end
