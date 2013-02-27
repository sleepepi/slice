class Project < ActiveRecord::Base

  mount_uploader :logo, ImageUploader

  # Concerns
  include Searchable, Deletable

  # Named Scopes
  scope :with_user, lambda { |arg| where(user_id: arg) }
  # scope :with_user, lambda { |*args| { conditions: ['projects.user_id IN (?)', args.first] } }
  scope :with_librarian, lambda { |*args| where('projects.user_id IN (?) or projects.id in (select project_users.project_id from project_users where project_users.user_id = ? and project_users.librarian IN (?))', args.first, args.first, args[1] ).references(:project_users) }
  # scope :with_librarian, lambda { |*args| { conditions: ['projects.user_id IN (?) or projects.id in (select project_users.project_id from project_users where project_users.user_id = ? and project_users.librarian IN (?))', args.first, args.first, args[1]] } }

  # Model Validation
  validates_presence_of :name, :user_id
  validates_uniqueness_of :name, scope: :deleted

  # Model Relationships
  belongs_to :user

  has_many :project_users
  has_many :users, -> { where( deleted: false ) }, through: :project_users, order: 'last_name, first_name'
  has_many :librarians, -> { where('project_users.librarian = ? and users.deleted = ?', true, false) }, through: :project_users, source: :user
  has_many :members, -> { where('project_users.librarian = ? and users.deleted = ?', false, false) }, through: :project_users, source: :user

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

  def custom_reports
    []
  end
end
