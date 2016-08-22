# frozen_string_literal: true

# Allows users to collaborate together to enter data across a series of
# subjects, events, and sites. Provides a method to share access with other
# users at varying degrees of control.
class Project < ApplicationRecord
  PER_PAGE = 40
  AUTO_LOCK_SHEETS = [
    ['Never Lock Sheets', 'never'],
    ['After 24 hours', 'after24hours'],
    ['After 1 week', 'after1week'],
    ['After 1 month', 'after1month']
  ]

  mount_uploader :logo, ImageUploader

  # Concerns
  include Searchable, Deletable, Sluggable

  attr_accessor :site_name

  after_save :create_default_site, :create_default_categories

  # Scopes
  scope :with_user, -> (arg) { where user_id: arg }
  scope :with_editor, -> (*args) { where('projects.user_id = ? or projects.id in (select project_users.project_id from project_users where project_users.user_id = ? and project_users.editor IN (?))', args.first, args.first, args[1] ).references(:project_users) }
  scope :by_favorite, -> (arg) { joins("LEFT JOIN project_favorites ON project_favorites.project_id = projects.id and project_favorites.user_id = #{arg.to_i}").references(:project_favorites) }
  scope :archived, -> { where(project_favorites: { archived: true }) }
  scope :unarchived, -> { where(project_favorites: { archived: [nil, false] }) }
  scope :viewable_by_user, -> (arg) { where('projects.id IN (SELECT projects.id FROM projects WHERE projects.user_id = ?)
    OR projects.id IN (SELECT project_users.project_id FROM project_users WHERE project_users.user_id = ?)
    OR projects.id IN (SELECT sites.project_id FROM site_users, sites WHERE site_users.site_id = sites.id AND site_users.user_id = ?)', arg, arg, arg) }

  scope :editable_by_user, -> (arg) { where('projects.id IN (SELECT projects.id FROM projects WHERE projects.user_id = ?)
    OR projects.id IN (SELECT project_users.project_id FROM project_users WHERE project_users.user_id = ? and project_users.editor = ?)
    OR projects.id IN (SELECT sites.project_id FROM site_users, sites WHERE site_users.site_id = sites.id AND site_users.user_id = ? and site_users.editor = ?)', arg, arg, true, arg, true) }

  # Model Validation
  validates :name, :user_id, presence: true
  validates :slug, uniqueness: { scope: :deleted }, allow_blank: true
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ }, allow_blank: true

  # Model Relationships
  belongs_to :user

  has_many :project_users
  has_many :users, -> { current.order(:last_name, :first_name) }, through: :project_users
  has_many :editors, -> { where('project_users.editor = ? and users.deleted = ?', true, false) }, through: :project_users, source: :user
  has_many :viewers, -> { where('project_users.editor = ? and users.deleted = ?', false, false) }, through: :project_users, source: :user
  has_many :site_users
  has_many :project_favorites
  has_many :adverse_events, -> { current.joins(:subject).merge(Subject.current) }
  has_many :categories, -> { where(deleted: false).order(:position) }
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

  # Model Methods

  def name_with_date_for_file
    "#{name_for_file}_#{Time.zone.today.strftime('%Y%m%d')}"
  end

  def name_for_file
    name.gsub(/[^a-zA-Z0-9_]/, '_')
  end

  def recent_sheets
    sheets.where('created_at > ?', (Time.zone.now.monday? ? Time.zone.now - 3.day : Time.zone.now - 1.day))
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

  def designs_with_event
    designs.joins(:event_designs)
  end

  def designs_without_event
    designs.where.not(id: designs_with_event.select(:id))
  end

  def can_edit_sheets_and_subjects?(current_user)
    current_user.all_sheet_editable_projects.where(id: id).count == 1
  end

  def subject_code_name_full
    subject_code_name.to_s.strip.blank? ? 'Subject Code' : subject_code_name.to_s.strip
  end

  def users_to_email
    result = (users + [user] + sites.collect(&:users).flatten).uniq
    result.select(&:emails_enabled?)
  end

  # Returns "fake" constructed variables like 'site' and 'sheet_date'
  def variable_by_id(variable_id)
    if variable_id == 'design'
      Variable.design(id)
    elsif variable_id == 'site'
      Variable.site(id)
    elsif variable_id == 'sheet_date'
      Variable.sheet_date(id)
    else
      variables.find_by_id(variable_id)
    end
  end

  def create_valid_subject(email, site_id)
    create_default_site if sites.count == 0
    hexdigest = Digest::SHA1.hexdigest(Time.zone.now.usec.to_s)
    site = sites.find_by_id(site_id)
    site_id = sites.first.id unless site

    if email.blank?
      subject_code = hexdigest[0..12]
    elsif subjects.where(subject_code: email.to_s).size == 0
      subject_code = email.to_s
    else
      subject_code = "#{email} - #{hexdigest[0..8]}"
    end
    subjects.create(subject_code: subject_code, site_id: site_id, email: email.to_s)
  end

  def favorited_by?(current_user)
    project_favorite = project_favorites.find_by user_id: current_user.id
    project_favorite.present? && project_favorite.favorite?
  end

  def unblinded?(current_user)
    !blinding_enabled? || user_id == current_user.id || project_users.where(user_id: current_user.id, unblinded: true).count > 0 || site_users.where(user_id: current_user.id, unblinded: true).count > 0
  end

  def archived_by?(current_user)
    project_favorite = project_favorites.find_by user_id: current_user.id
    if project_favorite
      project_favorite.archived?
    else
      false
    end
  end

  def show_type
    hide_values_on_pdfs? ? :display_name : :name
  end

  # Returns project editors and project owner
  def unblinded_project_editors
    return project_editors unless blinding_enabled
    User.current
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = #{id} and project_users.user_id = users.id")
      .where('(project_users.editor = ? and project_users.unblinded = ?) or users.id = ?', true, true, user_id)
  end

  def project_editors
    User.current
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = #{id} and project_users.user_id = users.id")
      .where('project_users.editor = ? or users.id = ?', true, user_id)
  end

  def unblinded_members
    return members unless blinding_enabled
    User.current
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = #{id} and project_users.user_id = users.id")
      .joins("LEFT OUTER JOIN site_users ON site_users.project_id = #{id} and site_users.user_id = users.id")
      .where('users.id = ? or project_users.unblinded = ? or site_users.unblinded = ?', user_id, true, true)
  end

  def members
    User.current
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = #{id} and project_users.user_id = users.id")
      .joins("LEFT OUTER JOIN site_users ON site_users.project_id = #{id} and site_users.user_id = users.id")
      .where('users.id = ? or project_users.unblinded IS NOT NULL or site_users.unblinded IS NOT NULL', user_id)
  end

  # Included unblinded project members and unblinded members for specified site
  def unblinded_members_for_site(site)
    return members_for_site(site) unless blinding_enabled
    User.current
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = #{id} and project_users.user_id = users.id")
      .joins("LEFT OUTER JOIN site_users ON site_users.project_id = #{id} and site_users.user_id = users.id and site_users.site_id = #{site.id}")
      .where('users.id = ? or project_users.unblinded = ? or site_users.unblinded = ?', user_id, true, true)
  end

  # Includes project members and site members for specified site
  def members_for_site(site)
    User.current
      .joins("LEFT OUTER JOIN project_users ON project_users.project_id = #{id} and project_users.user_id = users.id")
      .joins("LEFT OUTER JOIN site_users ON site_users.project_id = #{id} and site_users.user_id = users.id and site_users.site_id = #{site.id}")
      .where('users.id = ? or project_users.unblinded IS NOT NULL or site_users.unblinded IS NOT NULL', user_id)
  end

  def transfer_to_user(new_owner, current_user)
    update user_id: new_owner.id
    project_user = project_users.where(user_id: current_user.id).first_or_create(creator_id: new_owner.id)
    project_user.update editor: true
  end

  def auto_locking_enabled?
    ['', 'never'].exclude?(auto_lock_sheets)
  end

  private

  # Creates a default site if the project has no site associated with it
  def create_default_site
    return if sites.count > 0
    sites.create(
      name: site_name.blank? ? 'Default Site' : site_name,
      user_id: user_id
    )
  end

  def create_default_categories
    return if categories.count > 0
    categories.create(
      name: 'Adverse Events',
      slug: 'adverse-events',
      user_id: user_id,
      position: 1,
      use_for_adverse_events: true
    )
  end
end
