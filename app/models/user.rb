# frozen_string_literal: true

# The user class provides methods to scope resources in system that the user is
# allowed to view and edit.
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

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
  has_many :check_filter_values
  has_many :comments, -> { current }
  has_many :designs, -> { current }
  has_many :domains, -> { current }
  has_many :events, -> { current }
  has_many :exports, -> { current }
  has_many :handoffs
  has_many :notifications, -> { joins(:project).merge(Project.current) }
  has_many :projects, -> { current }
  has_many :project_preferences
  has_many :project_users
  has_many :randomization_schemes, -> { current }
  has_many :sections
  has_many :sheet_unlock_requests, -> { current.joins(:sheet).merge(Sheet.current) }
  has_many :sheets, -> { current.joins(:subject).merge(Subject.current) }
  has_many :sites, -> { current }
  has_many :site_users
  has_many :subjects, -> { current }
  has_many :tasks, -> { current }
  has_many :variables, -> { current }

  # Scopes

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

  # Model Methods

  def avatar_url(size = 80, default = 'mm')
    gravatar_id = Digest::MD5.hexdigest(email.to_s.downcase)
    "//gravatar.com/avatar/#{gravatar_id}.png?&s=#{size}&r=pg&d=#{default}"
  end

  def associated_users
    User
      .current
      .left_outer_joins(:projects, :project_users, :site_users)
      .where(
        'projects.id in (?) or project_users.project_id in (?) or site_users.project_id in (?)',
        all_viewable_and_site_projects.select(:id),
        all_viewable_and_site_projects.select(:id),
        all_viewable_and_site_projects.select(:id)
      )
      .distinct
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

  def all_designs
    Design
      .current
      .where(project_id: all_projects.select(:id))
      .blinding_scope(self)
  end

  def all_viewable_designs
    Design
      .current
      .where(project_id: all_viewable_and_site_projects.select(:id))
      .blinding_scope(self)
  end

  # Filters designs on a subject event by the user's blinded status
  def designs_on_subject_event(subject_event)
    all_viewable_designs.where(id: subject_event.event.designs.select(:id))
  end

  def all_events
    Event
      .current
      .where(project_id: all_projects.select(:id))
      .blinding_scope(self)
  end

  def all_viewable_events
    Event
      .current
      .where(project_id: all_viewable_and_site_projects.select(:id))
      .blinding_scope(self)
  end

  def all_variables
    Variable
      .current
      .where(project_id: all_projects.select(:id))
  end

  def all_viewable_variables
    Variable
      .current
      .where(project_id: all_viewable_and_site_projects.select(:id))
  end

  # Project Editors and Site Editors on that site can modify sheet
  def all_sheets
    Sheet
      .current
      .with_site(all_editable_sites.select(:id))
      .where(design_id: all_viewable_designs.select(:id))
      .left_outer_joins(:subject_event)
      .where('sheets.subject_event_id IS NULL or subject_events.event_id IS NULL or subject_events.event_id IN (?)', all_viewable_events.select(:id))
  end

  # Project Editors and Viewers and Site Members can view sheets
  def all_viewable_sheets
    Sheet
      .current
      .with_site(all_viewable_sites.select(:id))
      .where(design_id: all_viewable_designs.select(:id))
      .left_outer_joins(:subject_event)
      .where('sheets.subject_event_id IS NULL or subject_events.event_id IS NULL or subject_events.event_id IN (?)', all_viewable_events.select(:id))
  end

  # Filters sheets on a subject event by the user's blinded status
  def sheets_on_subject_event(subject_event)
    all_viewable_sheets
      .where(subject_event_id: subject_event.id)
      .where(design_id: subject_event.event.designs.select(:id))
  end

  def extra_sheets_on_subject_event(subject_event)
    all_viewable_sheets
      .where(subject_event_id: subject_event.id)
      .where.not(design_id: subject_event.event.designs.select(:id))
  end

  # Only Project Editors or Project Owner can modify randomization
  def all_randomizations
    Randomization
      .current
      .where(project_id: all_projects.select(:id))
      .blinding_scope(self)
  end

  # Project Editors and Viewers and Site Members can view randomization
  def all_viewable_randomizations
    Randomization
      .current
      .with_site(all_viewable_sites.select(:id))
      .blinding_scope(self)
  end

  # Only Project Editors and Site Editors can modify adverse event
  def all_adverse_events
    AdverseEvent
      .current
      .with_site(all_editable_sites.select(:id))
      .blinding_scope(self)
  end

  # Project Editors and Viewers and Site Members can view adverse event
  def all_viewable_adverse_events
    AdverseEvent
      .current
      .with_site(all_viewable_sites.select(:id))
      .blinding_scope(self)
  end

  def all_tasks
    task_scope = task_scope(all_editable_sites)
    task_scope_filtered(task_scope, all_subjects)
  end

  def all_viewable_tasks
    task_scope = task_scope(all_viewable_sites)
    task_scope_filtered(task_scope, all_viewable_subjects)
  end

  def task_scope(site_scope)
    Task.current
        .where(project_id: site_scope.select(:project_id))
        .includes(randomization_task: :randomization)
  end

  def task_scope_filtered(task_scope, subject_scope)
    task_scope.where(randomizations: { subject_id: nil }).or(
      task_scope.where(randomizations: { subject_id: subject_scope.select(:id) })
    ).blinding_scope(self)
  end

  def all_viewable_adverse_event_comments
    AdverseEventComment
      .current
      .where(adverse_event_id: all_viewable_adverse_events.select(:id))
  end

  # Comment creator can edit, or project editors and owners
  def all_adverse_event_comments
    AdverseEventComment
      .current
      .where('user_id = ? or project_id in (?)', id, all_projects.select(:id))
  end

  # Project Editors
  def all_sites
    Site.current.where(project_id: all_projects.select(:id))
  end

  # Project Editors and Viewers and Site Members
  def all_viewable_sites
    Site
      .current
      .with_project_or_as_site_user(all_viewable_projects.select(:id), id)
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
    Comment
      .current
      .where('sheet_id IN (?) or user_id = ?', all_sheets.select(:id), id)
  end

  def all_deletable_comments
    all_editable_comments
  end

  def sheets_with_comments(project)
    scope = all_viewable_sheets.where(project: project)
    scope.where(id: project.blinded_comments(self).select(:sheet_id))
  end

  def sheets_with_files(project)
    scope = all_viewable_sheets.where(project: project)
    scope.where(id: SheetVariable.with_files.select(:sheet_id))
         .or(scope.where(id: Grid.with_files.joins(:sheet_variable).select('sheet_variables.sheet_id')))
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
    return Project.none unless emails_enabled?
    all_viewable_and_site_projects
      .where(disable_all_emails: false)
      .left_outer_joins(:project_preferences)
      .where(project_preferences: { user_id: id, emails_enabled: [nil, true] })
  end

  def unread_notifications?
    notifications.where(read: false).present?
  end

  # All sheets created in the last day, or over the weekend if it's Monday
  # On Mon, returns sheets created since Fri morning (Time.zone.now - 3.days)
  # On Tue, returns sheets created since Mon morning (Time.zone.now - 1.day)
  def digest_sheets_created
    all_viewable_sheets
      .where(project_id: all_digest_projects.select(:id), missing: false)
      .where('sheets.created_at > ?', last_business_day)
  end

  def digest_comments
    all_viewable_comments
      .with_project(all_digest_projects.select(:id))
      .where('comments.created_at > ?', last_business_day)
      .order(:created_at)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def name_was
    "#{first_name_was} #{last_name_was}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

  def nickname
    "#{first_name} #{last_name.first}"
  end

  def last_business_day
    days = Time.zone.now.monday? ? 3.days : 1.day
    Time.zone.now - days
  end
end
