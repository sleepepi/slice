class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable

  # # Setup accessible (or protected) attributes for your model
  # attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :first_name, :last_name, :pagination

  serialize :pagination, Hash
  serialize :email_notifications, Hash

  # Callbacks
  after_create :notify_system_admins

  STATUS = ["active", "denied", "inactive", "pending"].collect{|i| [i,i]}

  EMAILABLES =  [
                  [ :daily_digest, 'Receive daily digest emails of sheets that have been created the previous day' ],
                  [ :sheet_comment, 'Receive email when a comment is added to a sheet' ]
                ]

  # Concerns
  include Contourable, Deletable

  # Named Scopes
  scope :human, -> { all } # Placeholder
  scope :status, lambda { |arg|  where( status: arg ) }
  scope :search, lambda { |arg| where( 'LOWER(first_name) LIKE ? or LOWER(last_name) LIKE ? or LOWER(email) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%') ) }
  scope :system_admins, -> { where( system_admin: true ) }
  scope :with_sheet, -> { where("users.id in (select DISTINCT(sheets.user_id) from sheets where sheets.deleted = ?)", false ) }
  scope :with_design, lambda { where("users.id in (select DISTINCT(designs.user_id) from designs where designs.deleted = ?)", false) }
  scope :with_variable_on_project, lambda { |arg| where("users.id in (select DISTINCT(variables.user_id) from variables where variables.project_id in (?) and variables.deleted = ?)", arg, false ) }
  scope :with_project, lambda { |*args| where("users.id in (select projects.user_id from projects where projects.id IN (?) and projects.deleted = ?) or users.id in (select project_users.user_id from project_users where project_users.project_id IN (?) and project_users.editor IN (?))", args.first, false, args.first, args[1] ) }

  # Model Validation
  validates_presence_of :first_name, :last_name

  # Model Relationships
  has_many :authentications
  has_many :comments, -> { where deleted: false }
  has_many :designs, -> { where deleted: false }
  has_many :exports, -> { where deleted: false }
  has_many :projects, -> { where deleted: false }
  has_many :reports, -> { where deleted: false }
  has_many :sheets, -> { where deleted: false }
  has_many :sites, -> { where deleted: false }
  has_many :subjects, -> { where deleted: false }
  has_many :variables, -> { where deleted: false }

  # User Methods

  def avatar_url(size = 80, default = 'mm')
    gravatar_id = Digest::MD5.hexdigest(self.email.to_s.downcase)
    "//gravatar.com/avatar/#{gravatar_id}.png?&s=#{size}&r=pg&d=#{default}"
  end

  def associated_users
    User.where( deleted: false ).with_project(self.all_projects.pluck(:id), [true, false])
  end

  def all_favorite_projects
    @all_favorite_projects ||= begin
      self.all_viewable_and_site_projects.by_favorite(self.id).where("project_favorites.favorite = ?", true).order('name')
    end
  end

  def pagination_count(model)
    self.pagination[model.to_s].to_i > 0 ? self.pagination[model.to_s].to_i : 25
  end

  def pagination_set!(model, count)
    original_pagination = self.pagination
    original_pagination[model.to_s] = count
    self.update_attributes pagination: original_pagination
  end

  def all_projects
    @all_projects ||= begin
      Project.current.with_editor(self.id, true)
    end
  end

  def all_viewable_projects
    @all_viewable_projects ||= begin
      Project.current.with_editor(self.id, [true, false])
    end
  end

  def all_viewable_and_site_projects
    @all_viewable_and_site_projects ||= begin
      Project.current.where(id: self.all_viewable_sites.pluck(:project_id) + self.all_viewable_projects.pluck(:id))
    end
  end

  # Project Owners, Project Editors, and Site Editors
  def all_sheet_editable_projects
    Project.current.where( id: self.all_projects.pluck(:id) + self.all_editable_sites.pluck(:project_id) )
  end

  def all_projects_or_site_editor_on_project(site_id)
    Project.current.where( id: self.all_projects.pluck(:id) + self.all_editable_sites.where( id: site_id ).pluck(:project_id) )
  end

  def all_reports
    @all_reports ||= begin
       Report.current.where(user_id: self.id)
    end
  end

  def all_viewable_reports
    @all_viewable_reports ||= begin
       Report.current.where(user_id: self.id)
    end
  end

  def all_designs
    @all_designs ||= begin
      Design.current.with_project(self.all_projects.pluck(:id))
    end
  end

  def all_viewable_designs
    @all_viewable_designs ||= begin
      Design.current.with_project(self.all_viewable_sites.pluck(:project_id) + self.all_viewable_projects.pluck(:id))
    end
  end

  def all_variables
    @all_variables ||= begin
      Variable.current.with_project(self.all_projects.pluck(:id))
    end
  end

  def all_viewable_variables
    @all_viewable_variables ||= begin
      Variable.current.with_project(self.all_viewable_projects.pluck(:id))
    end
  end

  # Project Editors and Site Editors on that site can modify sheet
  def all_sheets
    @all_sheets ||= begin
      Sheet.current.with_site(self.all_editable_sites.pluck(:id))
    end
  end

  # Project Editors and Viewers and Site Members can view sheets
  def all_viewable_sheets
    @all_viewable_sheets ||= begin
      Sheet.current.with_site(self.all_viewable_sites.pluck(:id))
    end
  end

  # Project Editors
  def all_sites
    @all_sites ||= begin
      Site.current.with_project(self.all_projects.pluck(:id))
    end
  end

  # Project Editors and Viewers and Site Members
  def all_viewable_sites
    @all_viewable_sites ||= begin
      Site.current.with_project_or_as_site_user(self.all_viewable_projects.pluck(:id), self)
    end
  end

  # Project Editors and Site Editors
  def all_editable_sites
    @all_editable_sites ||= begin
      Site.current.with_project_or_as_site_editor(self.all_projects.pluck(:id), self)
    end
  end

  # Project Editors and Site Editors can modify subjects
  def all_subjects
    @all_subjects ||= begin
      Subject.current.where( site_id: self.all_editable_sites.pluck(:id) )
    end
  end

  # Project Editors and Viewers and Site Members can view subjects
  def all_viewable_subjects
    @all_viewable_subjects ||= begin
      Subject.current.with_site(self.all_viewable_sites.pluck(:id))
    end
  end

  # Editors can only create subject if they can edit the specific site (all_projects_or_site_editor_on_project(site_id))
  def create_subject(project, subject_code, site_id, acrostic)
    if self.all_editable_sites.where( id: site_id, project_id: project.id ).count == 1
      if not subject_code.blank? and not site_id.blank?
        if subject = project.subjects.where( "LOWER(subjects.subject_code) = ?", subject_code.downcase ).first and self.all_editable_sites.where( id: subject.site_id, project_id: project.id ).count == 1
          # subject exists, and is on another "editable" site for user
          # Change subject to new "accepted site"
          subject.update( acrostic: acrostic, site_id: site_id )
        else
          # subject does not exist, attempt to create new subject
          subject = project.subjects.where( subject_code: subject_code, site_id: site_id ).first_or_create( user_id: self.id, acrostic: acrostic )
        end
      end

      subject
    else
      nil
    end
  end

  def all_exports
    @all_exports ||= begin
      Export.current.where(user_id: self.id)
    end
  end

  def all_viewable_exports
    @all_viewable_exports ||= begin
      Export.current.where(user_id: self.id)
    end
  end

  def unviewed_active_exports
    @unviewed_active_exports ||= begin
      self.all_viewable_exports.where(status: 'ready', viewed: false)
    end
  end

  def unviewed_pending_exports
    @unviewed_pending_exports ||= begin
      self.all_viewable_exports.where(status: 'pending', viewed: false)
    end
  end

  def all_comments
    @all_comments ||= begin
      self.comments
    end
  end

  def all_viewable_comments
    @all_viewable_comments ||= begin
      Comment.current.where(sheet_id: self.all_viewable_sheets.pluck(:id))
    end
  end

  def all_deletable_comments
    @all_deletable_comments ||= begin
      Comment.current.where("sheet_id IN (?) or user_id = ?", self.all_sheets.pluck(:id), self.id)
    end
  end

  # Overriding Devise built-in active_for_authentication? method
  def active_for_authentication?
    super and self.status == 'active' and not self.deleted?
  end

  def destroy
    super
    update_column :status, 'inactive'
    update_column :updated_at, Time.now
  end

  def all_digest_projects
    @all_digest_projects ||= begin
      self.all_viewable_and_site_projects.where( disable_all_emails: false ).select{|p| self.email_on?(:send_email) and self.email_on?(:daily_digest) and self.email_on?("project_#{p.id}") and self.email_on?("project_#{p.id}_daily_digest") }
    end
  end

  # All sheets created in the last day, or over the weekend if it's Monday
  # Ex: On Monday, returns sheets created since Friday morning (Time.now - 3.day)
  # Ex: On Tuesday, returns sheets created since Monday morning (Time.now - 1.day)
  def digest_sheets_created
    @digest_sheets_created ||= begin
      self.all_viewable_sheets.with_subject_status('valid').where(project_id: self.all_digest_projects.collect{|p| p.id}).where("created_at > ?", (Time.now.monday? ? Time.now - 3.day : Time.now - 1.day))
    end
  end

  def digest_comments
    @digest_comments ||= begin
      self.all_viewable_comments.with_project(self.all_digest_projects.collect{|p| p.id}).where("created_at > ?", (Time.now.monday? ? Time.now - 3.day : Time.now - 1.day)).order('created_at ASC')
    end
  end

  def email_on?(value)
    [nil, true].include?(self.email_notifications[value.to_s])
  end

  def name
    "#{first_name} #{last_name}"
  end

  def reverse_name
    "#{last_name}, #{first_name}"
  end

  def apply_omniauth(omniauth)
    unless omniauth['info'].blank?
      self.first_name = omniauth['info']['first_name'] if first_name.blank?
      self.last_name = omniauth['info']['last_name'] if last_name.blank?
    end
    super
  end

  private

  def notify_system_admins
    User.current.system_admins.each do |system_admin|
      UserMailer.notify_system_admin(system_admin, self).deliver if Rails.env.production?
    end
  end
end
