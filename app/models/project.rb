class Project < ActiveRecord::Base

  mount_uploader :logo, ImageUploader

  # Concerns
  include Searchable, Deletable

  attr_accessor :site_name

  after_save :create_default_site

  # Named Scopes
  scope :with_user, lambda { |arg| where(user_id: arg) }
  scope :with_editor, lambda { |*args| where('projects.user_id IN (?) or projects.id in (select project_users.project_id from project_users where project_users.user_id = ? and project_users.editor IN (?))', args.first, args.first, args[1] ).references(:project_users) }
  scope :by_favorite, lambda { |arg| joins("LEFT JOIN project_favorites ON project_favorites.project_id = projects.id and project_favorites.user_id = #{arg.to_i}") }

  # Model Validation
  validates_presence_of :name, :user_id

  # Model Relationships
  belongs_to :user

  has_many :project_users
  has_many :users, -> { where( deleted: false ).order( 'last_name, first_name' ) }, through: :project_users
  has_many :editors, -> { where('project_users.editor = ? and users.deleted = ?', true, false) }, through: :project_users, source: :user
  has_many :viewers, -> { where('project_users.editor = ? and users.deleted = ?', false, false) }, through: :project_users, source: :user

  has_many :project_favorites

  has_many :designs, -> { where deleted: false }
  has_many :variables, -> { where deleted: false }
  has_many :sheets, -> { where deleted: false }
  has_many :sites, -> { where deleted: false }
  has_many :subjects, -> { where deleted: false }

  has_many :exports, -> { where deleted: false }

  has_many :contacts, -> { where deleted: false }
  has_many :documents, -> { where deleted: false }
  has_many :posts, -> { where deleted: false }
  has_many :links, -> { where deleted: false }

  has_many :domains, -> { where deleted: false }

  # Model Methods

  def recent_sheets
    self.sheets.with_subject_status('valid').where("created_at > ?", (Time.now.monday? ? Time.now - 3.day : Time.now - 1.day))
  end

  def editable_by?(current_user)
    @editable_by ||= begin
      current_user.all_projects.where(id: self.id).count == 1
    end
  end

  def sites_with_range
    self.sites.where("sites.code_minimum IS NOT NULL and sites.code_minimum != '' and sites.code_maximum IS NOT NULL and sites.code_maximum != ''").order('name')
  end

  def site_id_with_prefix(prefix)
    prefix_sites = self.sites.select{|s| not s.prefix.blank? and prefix.start_with?(s.prefix) }
    prefix_sites.size == 1 ? prefix_sites.first.id : nil
  end

  def subject_code_name_full
    self.subject_code_name.to_s.strip.blank? ? 'Subject Code' : self.subject_code_name.to_s.strip
  end

  def users_to_email
    result = (self.users + [self.user] + self.sites.collect{|s| s.users}.flatten).uniq
    result = result.select{ |u| u.email_on?(:send_email) and u.email_on?("project_#{self.id}") }
  end

  # Returns "fake" constructed variables like 'site' and 'sheet_date'
  def variable_by_id(variable_id)
    if variable_id == 'design'
      Variable.design(self.id)
    elsif variable_id == 'site'
      Variable.site(self.id)
    elsif variable_id == 'sheet_date'
      Variable.sheet_date(self.id)
    else
      self.variables.find_by_id(variable_id)
    end
  end

  def create_valid_subject(email)
    self.create_default_site if self.sites.count == 0
    hexdigest = Digest::SHA1.hexdigest(Time.now.usec.to_s)
    if email.blank?
      subject_code = hexdigest[0..12]
    elsif self.subjects.where( subject_code: email.to_s ).size == 0
      subject_code = email.to_s
    else
      subject_code = "#{email.to_s} - #{hexdigest[0..8]}"
    end
    self.subjects.create( subject_code: subject_code, user_id: self.user_id, site_id: self.sites.first.id, status: 'valid', acrostic: '', email: email.to_s )
  end

  def favorited_by?(current_user)
    project_favorite = self.project_favorites.find_by_user_id(current_user.id)
    not project_favorite.blank? and project_favorite.favorite?
  end

  private

    # Creates a default site if the project has no site associated with it
    def create_default_site
      if self.sites.count == 0
        self.sites.create(
          name: self.site_name.blank? ? "Default Site" : self.site_name,
          user_id: self.user_id,
          prefix: ''
        )
      end
    end

end
